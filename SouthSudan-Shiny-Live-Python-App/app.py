"""
South Sudan Health System Dashboard - Complete Integration
Health Facilities + ACLED Conflict Data + HDX IDP/Event Data + DEM (GeoTIFF)

Requirements:
pip install shiny pandas folium shinywidgets plotly acled requests
pip install rasterio numpy pillow matplotlib

Environment Variables (optional - for ACLED):
export ACLED_API_KEY="your_api_key"
export ACLED_EMAIL="your_email@example.com"

Run:
shiny run app.py

Access: http://localhost:8000
"""

from shiny import App, render, ui, reactive
from shinywidgets import output_widget, render_widget
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import folium
from folium.plugins import MarkerCluster
import io
from datetime import datetime, timedelta
import os
import requests

# DEM GeoTIFF support
from functools import lru_cache
import base64
import numpy as np

# rasterio + matplotlib for rendering a GeoTIFF into a PNG overlay
import rasterio
from rasterio.warp import transform_bounds
import matplotlib.pyplot as plt
from matplotlib import cm as mpl_cm

# Try importing ACLED
try:
    from acled import AcledClient
    ACLED_AVAILABLE = True
except ImportError:
    ACLED_AVAILABLE = False
    print("� ACLED not installed. Run: pip install acled")

# -----------------------------------------------------------------------------
# Helper: locate data files (supports local dir + /mnt/data used by shiny-live)
# -----------------------------------------------------------------------------
def find_data_file(filename: str):
    candidates = [
        filename,
        os.path.join(os.getcwd(), filename),
        os.path.join("/mnt/data", filename),
        os.path.join(os.path.dirname(__file__), filename) if "__file__" in globals() else filename,
    ]
    for p in candidates:
        if p and os.path.exists(p):
            return p
    return None

FACILITIES_PATH = find_data_file("SouthSudanHealthFacilities1282026.csv")

# DEM GeoTIFF path (your file is /mnt/data/SSDDEMclip.tif in shiny-live)
DEM_TIF_PATH = find_data_file("SSDDEMclip.tif")

# HSTP Discontinued facilities
HSTP_DISCONTINUED = {
    "Lokiliri PHCC", "Ngangalla PHCU", "Jonkok PHCU", "Kenyi PHCU",
    "Lengi PHCU", "Kubi PHCU", "Litoba PHCU", "Maridi PHCU", "Jondoki PHCC",
    "Hai Jebel PHCC", "Khor Romula PHCC", "Rejaf East PHCC", "Logwili PHCU",
    "Nangoletirae PHCU", "New Site Wudran", "Pogee PHCU", "Logongawate PHCU",
    "Narus CDOT PHCC", "Duk Lost Boy Hospital", "Kolanyang PHCU", "Khorfulus PHCC",
    "Pajut Kurgai PHCC", "Patai PHCU", "Mathiang PHCU", "Tong PHCU", "Koyom Island PHCU",
    "Jalle PHCC", "Koat Nyakoang PHCU", "Bariak PHCU", "Padek PHCC", "Malual Bab PHCC",
    "Kiir Mayardit Women Hospital", "Agancy PHCU", "Mangang PHCU", "Wungiir PHCU",
    "Akum PHCC", "Warchui PHCU", "Jaac PPF PHCU", "Labarab PHCU", "Ajuongthok PHCC",
    "Bonki PHCU", "Madol PHCU", "Pathiel PHCU", "Nakdiar PHCU", "Bol PHCU",
    "Pariak PHCU", "Kierwanding PHCU", "Dhekdhek PHCU", "Mallo PHCU", "Pakwar PHCU",
    "Nasir Hospital", "Aweth PHCC", "Dingkar PHCU", "Bam PHCC", "Dangaji PHCU",
    "Thorgwang PHCU", "Mading PHCC", "Gurnyang PHCU", "Nilla PHCU", "Wau Shilluk PHCC",
    "Ying PHCU", "Dura PHCU", "Gasm Allah PHCU", "Lual Yak PHCU", "Melut Civil Hospital",
    "Mathiang Hospital", "Gollo PHCU", "Ulang PHCC", "Guelguk PHCC", "Riang PHCU",
    "Anakdiar PHCU", "Keet PHCC", "Malou-Hol PHCU", "Pakor PHCU", "Deleba PHCU",
    "RocRoc Dong PHCU", "Agok PHCC", "East Bank PHCC", "Achong Chong PHCC",
    "Li Rangu PHCC", "Nadiagere PHCC", "Matato PHCU", "Nangongo PHCU", "Matakurungu PHCU",
    "Gabat PHCU", "Bangasu PHCC", "Bahr Grindi PHCU", "Kuro PHCU", "Mabia PHCU",
    "Akpa PHCU", "Gamunakpe PHCU", "Ngboko PHCU", "Mabaiku PHCU", "Mabenge PHCU",
    "Minga PHCC", "Nabaria PHCU", "Nzama PHCU", "Mangburu PHCU", "Bakiringba PHCU",
    "Sinakpuro PHCU"
}

# ============================================================================
# DEM (GeoTIFF) HELPERS (cached)
# ============================================================================

def _normalize_to_uint8(arr: np.ndarray, vmin: float, vmax: float) -> np.ndarray:
    """Normalize float array to uint8 [0,255], clipping to vmin/vmax."""
    if vmax <= vmin:
        vmax = vmin + 1e-6
    a = np.clip(arr, vmin, vmax)
    a = (a - vmin) / (vmax - vmin)
    return (a * 255).astype(np.uint8)

@lru_cache(maxsize=1)
def load_dem_tif_overlay(max_size_px=1200, cmap_name="terrain"):
    """
    Read GeoTIFF, downsample for web display, render to PNG, and return:
      - data_uri: 'data:image/png;base64,...'
      - bounds_wgs84: [[south, west], [north, east]]
      - stats: dict with vmin/vmax
    """
    if not DEM_TIF_PATH:
        return None

    try:
        with rasterio.open(DEM_TIF_PATH) as ds:
            # Bounds in WGS84 for folium
            if ds.crs:
                west, south, east, north = transform_bounds(ds.crs, "EPSG:4326", *ds.bounds, densify_pts=21)
            else:
                # If CRS missing, assume it's already EPSG:4326
                west, south, east, north = ds.bounds.left, ds.bounds.bottom, ds.bounds.right, ds.bounds.top

            # Read band 1
            band1 = ds.read(1, masked=True)

            # Convert masked to float with NaNs
            arr = band1.astype("float32")
            if np.ma.isMaskedArray(arr):
                arr = arr.filled(np.nan)

            # Downsample to keep the PNG reasonable in size
            h, w = arr.shape
            scale = max(h / max_size_px, w / max_size_px, 1.0)
            if scale > 1.0:
                step = int(np.ceil(scale))
                arr_ds = arr[::step, ::step]
            else:
                arr_ds = arr

            # Robust min/max (ignore NaNs)
            finite = np.isfinite(arr_ds)
            if not finite.any():
                return None

            # Percentile stretch makes DEMs look better than raw min/max
            vmin = float(np.nanpercentile(arr_ds, 2))
            vmax = float(np.nanpercentile(arr_ds, 98))

            u8 = _normalize_to_uint8(arr_ds, vmin, vmax)

            # Apply colormap -> RGBA
            cmap = mpl_cm.get_cmap(cmap_name)
            rgba = cmap(u8 / 255.0)  # float RGBA [0,1]
            rgba_u8 = (rgba * 255).astype(np.uint8)

            # Make nodata transparent
            alpha = np.where(np.isfinite(arr_ds), 200, 0).astype(np.uint8)  # semi-transparent land
            rgba_u8[..., 3] = alpha

            # Encode PNG in memory
            buf = io.BytesIO()
            plt.imsave(buf, rgba_u8, format="png")
            png_bytes = buf.getvalue()
            b64 = base64.b64encode(png_bytes).decode("ascii")
            data_uri = f"data:image/png;base64,{b64}"

            bounds = [[south, west], [north, east]]
            return {
                "data_uri": data_uri,
                "bounds": bounds,
                "vmin": vmin,
                "vmax": vmax,
                "cmap": cmap_name,
            }

    except Exception as e:
        print(f"� DEM GeoTIFF load/render error: {e}")
        return None

# ============================================================================
# DATA LOADING FUNCTIONS
# ============================================================================

def load_facilities():
    """Load health facility data from CSV (supports /mnt/data on shiny-live)."""
    try:
        if not FACILITIES_PATH:
            raise FileNotFoundError("SouthSudanHealthFacilities1282026.csv not found (local dir or /mnt/data).")

        df = pd.read_csv(FACILITIES_PATH)

        # Clean data
        df = df[(df["Latitude"] != 0) & (df["Longitude"] != 0)]
        df = df[df["Latitude"].notna() & df["Longitude"].notna()]

        # Add calculated columns
        df["Functional"] = df["Functional"].astype(str)
        df["IsFunctional"] = df["Functional"].str.lower().str.contains("functional") & \
                             ~df["Functional"].str.lower().str.contains("non")

        df["Facility_T"] = df["Facility_T"].astype(str)
        df["Facility_N"] = df["Facility_N"].astype(str)

        df["IsHospital"] = df["Facility_T"].str.contains("Hospital", na=False) | (df["Facility_T"] == "TH")

        df["IsHSTP"] = df["Facility_N"].apply(lambda x: x.replace("/", " ").strip() in HSTP_DISCONTINUED)

        # Clean text fields
        for col in ["State", "County", "Facility_N", "Facility_T"]:
            if col in df.columns:
                df[col] = df[col].astype(str).str.replace("/", " ").str.strip()

        print(f" Loaded {len(df):,} health facilities")
        return df

    except Exception as e:
        print(f"� Facilities: {e}")
        return create_sample_facilities()

def load_idmc_events():
    """Load IDP/displacement event data from HDX."""
    hdx_url = "https://data.humdata.org/dataset/b22850c5-cece-4382-9dbf-0b30b4090ee7/resource/78eb1954-8150-4e6b-bafd-c0b39285e637/download/event_data_ssd.csv"
    try:
        print("=� Fetching IDP event data from HDX...")
        df = pd.read_csv(hdx_url)

        # Parse dates
        if "event_start_date" in df.columns:
            df["event_start_date"] = pd.to_datetime(df["event_start_date"], errors="coerce")

        # Ensure numeric fields
        if "figure" in df.columns:
            df["figure"] = pd.to_numeric(df["figure"], errors="coerce").fillna(0)

        # Add year for filtering
        if "year" not in df.columns and "event_start_date" in df.columns:
            df["year"] = df["event_start_date"].dt.year

        print(f" Loaded {len(df):,} IDP events from HDX")
        return df

    except Exception as e:
        print(f"� HDX IDP data error: {e}")
        return create_sample_idp_data()

def load_acled_data(days_back=180, limit=500):
    """Fetch conflict event data from ACLED (falls back to sample if unavailable)."""
    if not ACLED_AVAILABLE:
        print("9 ACLED package not available - using sample data")
        return create_sample_acled_data()

    try:
        client = AcledClient()

        end_date = datetime.now()
        start_date = end_date - timedelta(days=days_back)

        filters = {
            "limit": limit,
            "country": "South Sudan",
            "event_date": f"{start_date.strftime('%Y-%m-%d')}|{end_date.strftime('%Y-%m-%d')}"
        }

        print(f"=� Fetching ACLED data ({days_back} days)...")
        events = client.get_data(params=filters)

        if events:
            df = pd.DataFrame(events)
            df["event_date"] = pd.to_datetime(df["event_date"], errors="coerce")
            df["fatalities"] = pd.to_numeric(df.get("fatalities", 0), errors="coerce").fillna(0)
            df["latitude"] = pd.to_numeric(df.get("latitude", None), errors="coerce")
            df["longitude"] = pd.to_numeric(df.get("longitude", None), errors="coerce")
            df = df[df["event_date"].notna()]

            print(f" Loaded {len(df)} conflict events")
            return df

        return create_sample_acled_data()

    except Exception as e:
        print(f"� ACLED error: {e}")
        return create_sample_acled_data()

def create_sample_facilities():
    """Sample facility data."""
    import numpy as np
    n = 30
    data = {
        "State": np.random.choice(["Central Equatoria", "Upper Nile", "Jonglei"], n),
        "County": ["Sample County"] * n,
        "Facility_N": [f"Facility {i}" for i in range(n)],
        "Facility_T": np.random.choice(["PHCU", "PHCC", "County Hospital"], n),
        "Owner": ["MoH"] * n,
        "Latitude": np.random.uniform(4.5, 9.5, n),
        "Longitude": np.random.uniform(28.0, 33.0, n),
        "Functional": np.random.choice(["Functional", "Non Functional"], n),
    }
    df = pd.DataFrame(data)
    df["IsFunctional"] = df["Functional"].str.lower().str.contains("functional") & ~df["Functional"].str.lower().str.contains("non")
    df["IsHospital"] = df["Facility_T"].str.contains("Hospital", na=False)
    df["IsHSTP"] = False
    return df

def create_sample_acled_data():
    """Sample conflict data."""
    import numpy as np
    n = 50
    data = {
        "event_date": pd.date_range(end=datetime.now(), periods=n, freq="3D"),
        "latitude": np.random.uniform(4.0, 10.0, n),
        "longitude": np.random.uniform(27.0, 34.0, n),
        "event_type": np.random.choice(["Battles", "Violence against civilians", "Riots"], n),
        "fatalities": np.random.choice([0, 1, 2, 3, 5, 8, 12], n),
        "admin1": np.random.choice(["Unity", "Upper Nile", "Jonglei"], n),
    }
    return pd.DataFrame(data)

def create_sample_idp_data():
    """Sample IDP event data."""
    import numpy as np
    n = 30
    data = {
        "event_start_date": pd.date_range(end=datetime.now(), periods=n, freq="7D"),
        "admin1": np.random.choice(["Unity", "Upper Nile", "Jonglei", "Central Equatoria"], n),
        "admin2": ["Sample Location"] * n,
        "figure": np.random.randint(100, 5000, n),
        "displacement_type": np.random.choice(["Conflict", "Disaster", "Other"], n),
        "year": [2024, 2025, 2026] * 10
    }
    return pd.DataFrame(data)

# ============================================================================
# LOAD ALL DATA AT STARTUP
# ============================================================================

print("\n" + "="*70)
print("LOADING SOUTH SUDAN DATA")
print("="*70)

df_facilities = load_facilities()
df_acled = load_acled_data()
df_idp = load_idmc_events()

if DEM_TIF_PATH:
    print(f" DEM GeoTIFF found: {DEM_TIF_PATH}")
else:
    print("DEM GeoTIFF not found (SSDDEMclip.tif). Place it in local dir or /mnt/data.")

print("="*70)
print(" ALL DATA LOADED")
print("="*70 + "\n")

# ============================================================================
# UI DEFINITION
# ============================================================================

app_ui = ui.page_fluid(
    ui.tags.head(
        ui.tags.style("""
            .card {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                padding: 18px;
                border-radius: 8px;
                margin-bottom: 10px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            }
            .metric-value { font-size: 32px; font-weight: bold; line-height: 1; }
            .metric-label { font-size: 13px; opacity: 0.9; margin-top: 5px; }
            .alert-banner {
                background: linear-gradient(90deg, #dc2626 0%, #ea580c 100%);
                color: white;
                padding: 15px;
                border-radius: 8px;
                margin-bottom: 15px;
            }
            .info-banner {
                background: linear-gradient(90deg, #0284c7 0%, #0369a1 100%);
                color: white;
                padding: 12px;
                border-radius: 8px;
                margin-bottom: 15px;
            }
        """)
    ),

    ui.div(
        ui.h3("South Sudan Crisis Dashboard",
              style="margin: 0 0 8px 0; font-weight: bold;"),
        ui.p(
            f"Health: {len(df_facilities):,} facilities (102 HSTP discontinued) | "
            f"Conflict: {len(df_acled)} events | "
            f"Displacement: {df_idp['figure'].sum():,.0f} IDPs tracked" if "figure" in df_idp.columns else
            f"Health: {len(df_facilities):,} facilities (102 HSTP discontinued) | "
            f"Conflict: {len(df_acled)} events | Displacement: (figure missing)",
            style="margin: 0; font-size: 13px; opacity: 0.95;"
        ),
        class_="alert-banner"
    ),

    ui.div(
        ui.p(
            "Sources: MoH Facilities | ACLED Conflict Events | HDX/IDMC Displacement Events | Updated: Jan 28, 2026",
            style="margin: 0; font-size: 12px;"
        ),
        class_="info-banner"
    ),

    ui.h1("South Sudan Health & Humanitarian Dashboard"),
    ui.p("Integrated Monitoring: Health Infrastructure, Conflict, and Population Displacement"),
    ui.hr(),

    ui.row(
        ui.column(2,
            ui.input_select(
                "state_filter",
                "State:",
                choices=["All States"] + sorted(df_facilities["State"].unique().tolist())
            )
        ),
        ui.column(2,
            ui.input_select(
                "status_filter",
                "Facility Status:",
                choices=["All", "Functional", "Non-Functional", "HSTP Only"]
            )
        ),
        ui.column(2,
            ui.input_select(
                "period_filter",
                "Time Period:",
                choices=["Last 30 days", "Last 90 days", "Last 180 days", "Last Year"],
                selected="Last 180 days"
            )
        ),
        ui.column(4,
            ui.input_checkbox_group(
                "map_layers",
                "Map Layers:",
                choices={
                    "facilities": "Facilities",
                    "conflict": "Conflict",
                    "idp": "IDP Events",
                    "dem": "Elevation (DEM GeoTIFF)"
                },
                selected=["facilities", "conflict", "idp"],
                inline=True
            )
        ),
        ui.column(2,
            ui.download_button("download_combined", "Download All",
                               style="margin-top: 25px; width: 100%;")
        )
    ),

    ui.hr(),

    ui.row(
        ui.column(2, ui.output_ui("card_facilities")),
        ui.column(2, ui.output_ui("card_functional")),
        ui.column(2, ui.output_ui("card_hstp")),
        ui.column(2, ui.output_ui("card_conflict")),
        ui.column(2, ui.output_ui("card_fatalities")),
        ui.column(2, ui.output_ui("card_idps"))
    ),

    ui.hr(),

    ui.navset_tab(
        ui.nav_panel("Integrated Map",
            ui.output_ui("integrated_map"),
            ui.br(),
            ui.output_text_verbatim("map_legend")
        ),

        ui.nav_panel("Health Facilities",
            ui.row(
                ui.column(6, output_widget("state_health_chart")),
                ui.column(6, output_widget("facility_type_chart"))
            ),
            ui.hr(),
            ui.h4("State Summary"),
            ui.output_data_frame("state_health_table")
        ),

        ui.nav_panel("Conflict Impact",
            ui.row(
                ui.column(6, output_widget("conflict_timeline")),
                ui.column(6, output_widget("conflict_type_chart"))
            ),
            ui.hr(),
            ui.h4("Conflict Events Near Health Facilities"),
            ui.output_ui("proximity_analysis"),
            ui.hr(),
            ui.output_data_frame("conflict_events_table")
        ),

        ui.nav_panel("Displacement",
            ui.row(
                ui.column(6, output_widget("idp_timeline")),
                ui.column(6, output_widget("idp_by_cause"))
            ),
            ui.hr(),
            ui.h4("Recent Displacement Events"),
            ui.output_data_frame("idp_events_table")
        ),

        ui.nav_panel("HSTP Impact",
            ui.row(
                ui.column(6, output_widget("hstp_state_chart")),
                ui.column(6, output_widget("hstp_type_chart"))
            ),
            ui.hr(),
            ui.h4("Root Cause Analysis"),
            ui.output_ui("hstp_analysis"),
            ui.hr(),
            ui.h4("102 HSTP Discontinued Facilities"),
            ui.output_data_frame("hstp_table")
        ),

        ui.nav_panel("Search",
            ui.input_text("search_box", "= Search:", placeholder="Facility name, county, state..."),
            ui.output_data_frame("facility_search_table")
        )
    ),

    ui.hr(),
    ui.p("Sources: South Sudan MoH | ACLED | HDX/IDMC | UNHCR | Updated: January 28, 2026",
         style="text-align: center; color: #666; font-size: 11px;")
)

# ============================================================================
# SERVER LOGIC
# ============================================================================

def server(input, output, session):

    # Reactive Data Filters
    @reactive.Calc
    def filtered_facilities():
        data = df_facilities.copy()

        if input.state_filter() != "All States":
            data = data[data["State"] == input.state_filter()]

        if input.status_filter() == "Functional":
            data = data[data["IsFunctional"] == True]
        elif input.status_filter() == "Non-Functional":
            data = data[data["IsFunctional"] == False]
        elif input.status_filter() == "HSTP Only":
            data = data[data["IsHSTP"] == True]

        if hasattr(input, "search_box") and input.search_box():
            search = input.search_box().lower()
            data = data[
                data["Facility_N"].str.lower().str.contains(search, na=False) |
                data["County"].str.lower().str.contains(search, na=False) |
                data["State"].str.lower().str.contains(search, na=False)
            ]

        return data

    @reactive.Calc
    def filtered_conflict():
        data = df_acled.copy()

        # Time filter
        days_map = {"Last 30 days": 30, "Last 90 days": 90,
                    "Last 180 days": 180, "Last Year": 365}
        days = days_map.get(input.period_filter(), 180)
        cutoff = datetime.now() - timedelta(days=days)

        if "event_date" in data.columns:
            data = data[data["event_date"] >= cutoff]

        # State filter
        if input.state_filter() != "All States" and "admin1" in data.columns:
            data = data[data["admin1"] == input.state_filter()]

        return data

    @reactive.Calc
    def filtered_idp():
        data = df_idp.copy()

        # Time filter
        days_map = {"Last 30 days": 30, "Last 90 days": 90,
                    "Last 180 days": 180, "Last Year": 365}
        days = days_map.get(input.period_filter(), 180)
        cutoff = datetime.now() - timedelta(days=days)

        if "event_start_date" in data.columns:
            data = data[data["event_start_date"] >= cutoff]

        # State filter
        if input.state_filter() != "All States" and "admin1" in data.columns:
            data = data[data["admin1"] == input.state_filter()]

        return data

    # ========================================================================
    # METRIC CARDS
    # ========================================================================

    @output
    @render.ui
    def card_facilities():
        total = len(filtered_facilities())
        return ui.div(
            ui.div(f"{total:,}", class_="metric-value"),
            ui.div("Health Facilities", class_="metric-label"),
            class_="card",
            style="background: linear-gradient(135deg, #3b82f6 0%, #1e40af 100%);"
        )

    @output
    @render.ui
    def card_functional():
        data = filtered_facilities()
        func = int(data["IsFunctional"].sum()) if "IsFunctional" in data.columns else 0
        rate = (func / len(data) * 100) if len(data) > 0 else 0
        return ui.div(
            ui.div(f"{func:,}", class_="metric-value"),
            ui.div(f"Functional ({rate:.1f}%)", class_="metric-label"),
            class_="card",
            style="background: linear-gradient(135deg, #22c55e 0%, #15803d 100%);"
        )

    @output
    @render.ui
    def card_hstp():
        hstp = int(filtered_facilities()["IsHSTP"].sum()) if "IsHSTP" in filtered_facilities().columns else 0
        return ui.div(
            ui.div(f"{hstp:,}", class_="metric-value"),
            ui.div("HSTP Discontinued", class_="metric-label"),
            class_="card",
            style="background: linear-gradient(135deg, #f97316 0%, #c2410c 100%);"
        )

    @output
    @render.ui
    def card_conflict():
        events = len(filtered_conflict())
        return ui.div(
            ui.div(f"{events:,}", class_="metric-value"),
            ui.div("Conflict Events", class_="metric-label"),
            class_="card",
            style="background: linear-gradient(135deg, #7c2d12 0%, #991b1b 100%);"
        )

    @output
    @render.ui
    def card_fatalities():
        fatal = float(filtered_conflict()["fatalities"].sum()) if "fatalities" in filtered_conflict().columns else 0.0
        return ui.div(
            ui.div(f"{fatal:.0f}", class_="metric-value"),
            ui.div("Fatalities", class_="metric-label"),
            class_="card",
            style="background: linear-gradient(135deg, #450a0a 0%, #7f1d1d 100%);"
        )

    @output
    @render.ui
    def card_idps():
        idps = float(filtered_idp()["figure"].sum()) if "figure" in filtered_idp().columns else 0.0
        return ui.div(
            ui.div(f"{idps:,.0f}", class_="metric-value"),
            ui.div("IDPs Displaced", class_="metric-label"),
            class_="card",
            style="background: linear-gradient(135deg, #7c3aed 0%, #5b21b6 100%);"
        )

    # ========================================================================
    # INTEGRATED MAP (UPDATED: DEM GeoTIFF overlay + auto-zoom to data extent)
    # ========================================================================

    @output
    @render.ui
    def integrated_map():
        fac_data = filtered_facilities()
        conflict_data = filtered_conflict()
        idp_data = filtered_idp()

        # Create map (fallback location; we will fit_bounds if we have points)
        m = folium.Map(location=[7.3, 30.2], zoom_start=6, tiles="OpenStreetMap")

        # Collect bounds from selected point layers so map zooms to visible data by default
        lats, lons = [], []

        if "facilities" in input.map_layers() and len(fac_data) > 0:
            lats.extend(fac_data["Latitude"].dropna().tolist())
            lons.extend(fac_data["Longitude"].dropna().tolist())

        if "conflict" in input.map_layers() and len(conflict_data) > 0:
            if "latitude" in conflict_data.columns and "longitude" in conflict_data.columns:
                lats.extend(conflict_data["latitude"].dropna().tolist())
                lons.extend(conflict_data["longitude"].dropna().tolist())

        if "idp" in input.map_layers() and len(idp_data) > 0:
            if "latitude" in idp_data.columns and "longitude" in idp_data.columns:
                lats.extend(idp_data["latitude"].dropna().tolist())
                lons.extend(idp_data["longitude"].dropna().tolist())

        # Layer 0: DEM (GeoTIFF) as ImageOverlay
        # NOTE: This does NOT stream tiles; it creates a PNG overlay (cached).
        if "dem" in input.map_layers():
            dem = load_dem_tif_overlay()
            if dem is None:
                folium.Marker(
                    [7.3, 30.2],
                    popup="DEM GeoTIFF not found or failed to render: SSDDEMclip.tif",
                    tooltip="DEM missing",
                    icon=folium.Icon(color="gray", icon="info-sign")
                ).add_to(m)
            else:
                dem_group = folium.FeatureGroup(name="Elevation (DEM GeoTIFF)").add_to(m)

                folium.raster_layers.ImageOverlay(
                    name="Elevation (DEM GeoTIFF)",
                    image=dem["data_uri"],
                    bounds=dem["bounds"],
                    opacity=0.65,
                    interactive=False,
                    cross_origin=False,
                    zindex=1
                ).add_to(dem_group)

                # If user only turns on DEM (no points), fit to DEM bounds
                if len(lats) == 0 and len(lons) == 0 and dem.get("bounds"):
                    try:
                        m.fit_bounds(dem["bounds"], padding=(20, 20))
                    except Exception:
                        pass

        # Layer 1: Health Facilities
        if "facilities" in input.map_layers():
            fac_cluster = MarkerCluster(name="Health Facilities").add_to(m)

            for _, row in fac_data.iterrows():
                color = "orange" if row["IsHSTP"] else \
                       ("blue" if row["IsHospital"] and row["IsFunctional"] else \
                        ("green" if row["IsFunctional"] else "red"))

                icon = "exclamation-triangle" if row["IsHSTP"] else \
                      ("hospital" if row["IsHospital"] else "medkit")

                popup = f"""
                <div style='min-width: 220px;'>
                    <h4 style='margin: 0 0 8px 0;'>{row['Facility_N']}</h4>
                    <table style='font-size: 12px;'>
                        <tr><td><b>Type:</b></td><td>{row['Facility_T']}</td></tr>
                        <tr><td><b>County:</b></td><td>{row['County']}</td></tr>
                        <tr><td><b>Status:</b></td><td><b style='color: {color};'>{row['Functional']}</b></td></tr>
                    </table>
                    {'<div style="background: #fed7aa; color: #c2410c; padding: 5px; margin-top: 5px; border-radius: 3px; text-align: center; font-weight: bold;">� HSTP DISCONTINUED</div>' if row['IsHSTP'] else ''}
                </div>
                """

                folium.Marker(
                    [row["Latitude"], row["Longitude"]],
                    popup=folium.Popup(popup, max_width=300),
                    tooltip=row["Facility_N"],
                    icon=folium.Icon(color=color, icon=icon, prefix="fa")
                ).add_to(fac_cluster)

        # Layer 2: Conflict Events
        if "conflict" in input.map_layers():
            conflict_group = folium.FeatureGroup(name="Conflict Events").add_to(m)

            for _, row in conflict_data.iterrows():
                if pd.isna(row.get("latitude")) or pd.isna(row.get("longitude")):
                    continue
                radius = 5 + (float(row.get("fatalities", 0)) * 2)

                folium.CircleMarker(
                    [row["latitude"], row["longitude"]],
                    radius=radius,
                    popup=f"<b>Conflict</b><br>{row.get('event_type', 'Unknown')}<br>{int(row.get('fatalities', 0))} fatalities",
                    tooltip=f"{row.get('event_type', 'Unknown')} - {int(row.get('fatalities', 0))} deaths",
                    color="#7c2d12",
                    fillColor="#991b1b",
                    fillOpacity=0.6,
                    weight=2
                ).add_to(conflict_group)

        # Layer 3: IDP Events
        if "idp" in input.map_layers() and "latitude" in idp_data.columns and "longitude" in idp_data.columns:
            idp_group = folium.FeatureGroup(name="IDP Events").add_to(m)

            for _, row in idp_data.iterrows():
                if pd.notna(row.get("latitude")) and pd.notna(row.get("longitude")):
                    figure = float(row.get("figure", 0) or 0)
                    size = max(5, min(figure / 100, 20))

                    folium.CircleMarker(
                        [row["latitude"], row["longitude"]],
                        radius=size,
                        popup=f"<b>Displacement</b><br>{row.get('displacement_type', 'Unknown')}<br>{int(figure)} IDPs",
                        tooltip=f"{int(figure)} people displaced",
                        color="#7c3aed",
                        fillColor="#a78bfa",
                        fillOpacity=0.5,
                        weight=2
                    ).add_to(idp_group)

        # Auto-fit map to point data bounds if we have points
        if len(lats) > 0 and len(lons) > 0:
            south = min(lats) - 0.25
            north = max(lats) + 0.25
            west = min(lons) - 0.25
            east = max(lons) + 0.25
            try:
                m.fit_bounds([[south, west], [north, east]], padding=(20, 20))
            except Exception:
                pass

        # Add layer control
        folium.LayerControl().add_to(m)

        map_html = m._repr_html_()
        return ui.HTML(
            f'<div style="height: 650px; border: 2px solid #ddd; border-radius: 8px; overflow: hidden;">{map_html}</div>'
        )

    @output
    @render.text
    def map_legend():
        fac = filtered_facilities()
        conf = filtered_conflict()
        idp = filtered_idp()
        dem = load_dem_tif_overlay() if ("dem" in input.map_layers()) else None

        dem_line = ""
        if dem:
            dem_line = f'  " DEM stretch: p2={dem["vmin"]:.1f} to p98={dem["vmax"]:.1f} (cmap={dem["cmap"]})\n'
        else:
            dem_line = '(DEM values shown when layer enabled)\n'

        return f"""
LEGEND:
Health Facilities:
  "Green = Functional | Red = Non-Functional | Orange = HSTP | Blue = Hospitals"

Conflict Events:
  "Circle size = fatalities | Larger = more deadly"

IDP Events:
  "Purple circles = displacement events"
  "Size = number of people displaced"

DEM Elevation (GeoTIFF):
  "Raster overlay (semi-transparent)"
{dem_line}
CURRENT VIEW:
  Facilities: {len(fac):,} | Conflict Events: {len(conf):,} | IDP Events: {len(idp):,}
  Period: {input.period_filter()} | State: {input.state_filter()}
        """

    # ========================================================================
    # PROXIMITY ANALYSIS
    # ========================================================================

    @output
    @render.ui
    def proximity_analysis():
        fac = filtered_facilities()
        conf = filtered_conflict()

        if len(conf) == 0:
            return ui.p("No conflict events in selected period")

        at_risk = 0
        for _, facility in fac.iterrows():
            nearby = conf[
                (abs(conf["latitude"] - facility["Latitude"]) < 0.45) &
                (abs(conf["longitude"] - facility["Longitude"]) < 0.45)
            ]
            if len(nearby) > 0:
                at_risk += 1

        risk_pct = (at_risk / len(fac) * 100) if len(fac) > 0 else 0

        if risk_pct > 30:
            color = "#dc2626"; level = "CRITICAL"
        elif risk_pct > 15:
            color = "#ea580c"; level = "HIGH"
        else:
            color = "#f59e0b"; level = "MODERATE"

        return ui.HTML(f"""
        <div style='background: #fef3c7; border-left: 4px solid {color}; padding: 15px; border-radius: 4px;'>
            <h4 style='margin: 0 0 10px 0; color: {color};'>Risk Assessment: {level}</h4>
            <p style='margin: 0; color: #78350f;'>
                <b>{at_risk}</b> facilities ({risk_pct:.1f}%) are within 50km of recent conflict events.
            </p>
            <p style='margin: 10px 0 0 0; font-size: 13px; color: #78350f;'>
                These facilities face elevated security risks and may require contingency planning,
                security assessments, or relocation of services.
            </p>
        </div>
        """)

    @output
    @render.ui
    def hstp_analysis():
        hstp_states = df_facilities[df_facilities["IsHSTP"]].groupby("State").size().sort_values(ascending=False)

        if "admin1" in df_acled.columns:
            conflict_states = df_acled.groupby("admin1").size().sort_values(ascending=False)

            insecurity_likely = []
            overlap_likely = []

            for state in hstp_states.index[:5]:
                hstp_count = int(hstp_states[state])
                conflict_count = int(conflict_states.get(state, 0))

                if conflict_count > 20:
                    insecurity_likely.append(f"{state} ({hstp_count} closures, {conflict_count} conflicts)")
                else:
                    overlap_likely.append(f"{state} ({hstp_count} closures, {conflict_count} conflicts)")

            analysis = f"""
            <div style='background: #f0f9ff; border: 1px solid #0284c7; padding: 15px; border-radius: 8px;'>
                <h4 style='margin: 0 0 10px 0; color: #0c4a6e;'>=� Root Cause Analysis</h4>

                <div style='margin-bottom: 10px;'>
                    <b style='color: #dc2626;'>Likely Insecurity-Driven Closures:</b><br>
                    {('<br>'.join(['" ' + s for s in insecurity_likely])) if insecurity_likely else '<i>None identified</i>'}
                </div>

                <div>
                    <b style='color: #f59e0b;'>Likely Service Overlap/Budget Closures:</b><br>
                    {('<br>'.join(['" ' + s for s in overlap_likely])) if overlap_likely else '<i>None identified</i>'}
                </div>

                <p style='margin: 10px 0 0 0; font-size: 12px; color: #64748b;'>
                    Analysis based on correlation between HSTP closures and conflict event density.
                </p>
            </div>
            """
        else:
            analysis = "<p>State-level conflict data needed for analysis</p>"

        return ui.HTML(analysis)

    # ========================================================================
    # CHARTS
    # ========================================================================

    @output
    @render_widget
    def state_health_chart():
        data = filtered_facilities()

        stats = data.groupby("State").agg(
            Total=("Facility_N", "count"),
            Functional=("IsFunctional", "sum")
        ).reset_index()
        stats["Non-Functional"] = stats["Total"] - stats["Functional"]
        stats = stats.sort_values("Total", ascending=True)

        fig = go.Figure()
        fig.add_trace(go.Bar(y=stats["State"], x=stats["Functional"],
                             name="Functional", orientation="h", marker_color="#22c55e"))
        fig.add_trace(go.Bar(y=stats["State"], x=stats["Non-Functional"],
                             name="Non-Functional", orientation="h", marker_color="#ef4444"))

        fig.update_layout(
            title="Health Facilities by State",
            barmode="stack",
            height=500,
            template="plotly_white"
        )

        return fig

    @output
    @render_widget
    def facility_type_chart():
        type_counts = filtered_facilities()["Facility_T"].value_counts().reset_index()
        type_counts.columns = ["Type", "Count"]

        fig = px.pie(type_counts, values="Count", names="Type",
                     title="Facility Type Distribution", hole=0.4)
        fig.update_layout(height=500)
        return fig

    @output
    @render_widget
    def conflict_timeline():
        conf = filtered_conflict()
        if len(conf) == 0 or "event_date" not in conf.columns:
            return go.Figure().add_annotation(text="No conflict data")

        daily = (
            conf.groupby(conf["event_date"].dt.date)
            .agg(Events=("fatalities", "size"), Fatalities=("fatalities", "sum"))
            .reset_index()
            .rename(columns={"event_date": "Date"})
        )

        fig = go.Figure()
        fig.add_trace(go.Scatter(x=daily["Date"], y=daily["Events"],
                                 name="Events", line=dict(color="#f97316", width=2)))
        fig.add_trace(go.Bar(x=daily["Date"], y=daily["Fatalities"],
                             name="Fatalities", marker_color="#7c2d12", opacity=0.6))

        fig.update_layout(title="Conflict Events Over Time", height=400, template="plotly_white")
        return fig

    @output
    @render_widget
    def conflict_type_chart():
        conf = filtered_conflict()
        if len(conf) == 0:
            return go.Figure().add_annotation(text="No data")

        types = conf.groupby("event_type").agg(
            Events=("event_type", "size"),
            Fatalities=("fatalities", "sum")
        ).reset_index()

        fig = px.bar(types, x="event_type", y=["Events", "Fatalities"],
                     title="Conflict by Type", barmode="group")
        fig.update_layout(height=400, template="plotly_white")
        fig.update_xaxes(tickangle=45)
        return fig

    @output
    @render_widget
    def idp_timeline():
        idp = filtered_idp()
        if len(idp) == 0 or "event_start_date" not in idp.columns or "figure" not in idp.columns:
            return go.Figure().add_annotation(text="No IDP data")

        monthly = idp.groupby(idp["event_start_date"].dt.to_period("M")).agg(
            figure=("figure", "sum")
        ).reset_index()
        monthly["event_start_date"] = monthly["event_start_date"].astype(str)

        fig = px.area(monthly, x="event_start_date", y="figure",
                      title="Displacement Events Over Time",
                      labels={"figure": "Number of IDPs", "event_start_date": "Month"})
        fig.update_layout(height=400, template="plotly_white")
        return fig

    @output
    @render_widget
    def idp_by_cause():
        idp = filtered_idp()
        if len(idp) == 0 or "displacement_type" not in idp.columns or "figure" not in idp.columns:
            return go.Figure().add_annotation(text="No displacement type data")

        by_cause = idp.groupby("displacement_type").agg(
            IDPs=("figure", "sum")
        ).reset_index()

        fig = px.bar(by_cause, x="displacement_type", y="IDPs",
                     title="Displacement by Cause")
        fig.update_layout(height=400, template="plotly_white")
        return fig

    @output
    @render_widget
    def hstp_state_chart():
        hstp = df_facilities[df_facilities["IsHSTP"] == True]
        counts = hstp["State"].value_counts().reset_index()
        counts.columns = ["State", "Count"]

        fig = px.bar(counts, x="State", y="Count",
                     title="HSTP Discontinued by State",
                     text="Count")
        fig.update_traces(textposition="outside")
        fig.update_layout(height=400, showlegend=False)
        fig.update_xaxes(tickangle=45)
        return fig

    @output
    @render_widget
    def hstp_type_chart():
        hstp = df_facilities[df_facilities["IsHSTP"] == True]
        types = hstp["Facility_T"].value_counts().reset_index()
        types.columns = ["Type", "Count"]

        fig = px.treemap(types, path=["Type"], values="Count",
                         title="HSTP by Facility Type")
        fig.update_layout(height=400)
        return fig

    # ========================================================================
    # DATA TABLES
    # ========================================================================

    @output
    @render.data_frame
    def state_health_table():
        data = filtered_facilities()

        summary = data.groupby("State").agg(
            Total=("Facility_N", "count"),
            Functional=("IsFunctional", "sum"),
            HSTP=("IsHSTP", "sum")
        ).reset_index()

        summary["Non-Functional"] = summary["Total"] - summary["Functional"]
        summary["Functional %"] = (summary["Functional"] / summary["Total"] * 100).round(1)
        summary = summary.sort_values("HSTP", ascending=False)

        return render.DataGrid(summary, width="100%", height="400px")

    @output
    @render.data_frame
    def conflict_events_table():
        conf = filtered_conflict()

        if len(conf) == 0:
            return render.DataGrid(pd.DataFrame({"Message": ["No events"]}))

        display = conf[["event_date", "event_type", "fatalities"]].copy()
        if "admin1" in conf.columns:
            display["State"] = conf["admin1"]

        display = display.sort_values("event_date", ascending=False).head(100)
        display["event_date"] = display["event_date"].dt.strftime("%Y-%m-%d")
        display.columns = ["Date", "Type", "Fatalities"] + (["State"] if "admin1" in conf.columns else [])

        return render.DataGrid(display, width="100%", height="400px")

    @output
    @render.data_frame
    def idp_events_table():
        idp = filtered_idp()

        if len(idp) == 0:
            return render.DataGrid(pd.DataFrame({"Message": ["No IDP events"]}))

        cols_to_show = []
        if "event_start_date" in idp.columns:
            cols_to_show.append("event_start_date")
        if "figure" in idp.columns:
            cols_to_show.append("figure")
        if "admin1" in idp.columns:
            cols_to_show.append("admin1")
        if "admin2" in idp.columns:
            cols_to_show.append("admin2")
        if "displacement_type" in idp.columns:
            cols_to_show.append("displacement_type")

        display = idp[cols_to_show].copy()
        if "event_start_date" in display.columns:
            display = display.sort_values("event_start_date", ascending=False).head(100)
            display["event_start_date"] = display["event_start_date"].dt.strftime("%Y-%m-%d")

        return render.DataGrid(display, width="100%", height="400px")

    @output
    @render.data_frame
    def hstp_table():
        hstp = df_facilities[df_facilities["IsHSTP"] == True]
        display = hstp[["State", "County", "Facility_N", "Facility_T", "Functional"]].copy()
        display.columns = ["State", "County", "Facility Name", "Type", "Status"]
        display = display.sort_values(["State", "County"])
        return render.DataGrid(display, width="100%", height="500px")

    @output
    @render.data_frame
    def facility_search_table():
        data = filtered_facilities()
        display = data[["State", "County", "Facility_N", "Facility_T", "Functional", "IsHSTP"]].copy()
        display.columns = ["State", "County", "Name", "Type", "Status", "HSTP"]
        display["HSTP"] = display["HSTP"].map({True: "� Yes", False: "No"})
        return render.DataGrid(display, width="100%", height="600px")

    # ========================================================================
    # DOWNLOADS
    # ========================================================================

    @output
    @render.download(filename="south_sudan_complete_data.csv")
    def download_combined():
        """Download all three datasets"""
        buffer = io.StringIO()

        # Facilities
        buffer.write("# HEALTH FACILITIES\n")
        fac = filtered_facilities()[["State", "County", "Facility_N", "Facility_T",
                                     "Latitude", "Longitude", "Functional", "IsHSTP"]]
        fac.to_csv(buffer, index=False)

        # Conflict
        buffer.write("\n\n# CONFLICT EVENTS\n")
        conf = filtered_conflict()
        if len(conf) > 0:
            conf_export = conf[["event_date", "event_type", "fatalities", "latitude", "longitude"]].copy()
            if "admin1" in conf.columns:
                conf_export["State"] = conf["admin1"]
            conf_export.to_csv(buffer, index=False)

        # IDPs
        buffer.write("\n\n# DISPLACEMENT EVENTS\n")
        idp = filtered_idp()
        if len(idp) > 0:
            idp.to_csv(buffer, index=False)

        yield buffer.getvalue()

# Create app
app = App(app_ui, server)

if __name__ == "__main__":
    from shiny import run_app
    run_app(app, host="0.0.0.0", port=8000)