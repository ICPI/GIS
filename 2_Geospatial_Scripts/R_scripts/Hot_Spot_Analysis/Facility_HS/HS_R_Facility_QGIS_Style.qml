<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis version="3.8.0-Zanzibar" hasScaleBasedVisibilityFlag="0" maxScale="0" simplifyMaxScale="1" styleCategories="AllStyleCategories" simplifyDrawingHints="0" simplifyDrawingTol="1" labelsEnabled="0" simplifyAlgorithm="0" minScale="1e+08" simplifyLocal="1" readOnly="0">
  <flags>
    <Identifiable>1</Identifiable>
    <Removable>1</Removable>
    <Searchable>1</Searchable>
  </flags>
  <renderer-v2 symbollevels="0" forceraster="0" type="RuleRenderer" enableorderby="0">
    <rules key="{022d0e93-b3bd-445e-847a-906a61359801}">
      <rule label="coldspot 99% confidence" key="{92014674-0d51-41b9-9d49-eacccb0b9ddd}" filter="&quot;Zscore&quot; &lt;= -2.58 AND &quot;pvalue&quot; &lt;= 0.01" symbol="0"/>
      <rule label="coldspot 95% confidence" key="{0972bbda-48ca-426f-b10d-3804ec63c350}" filter="&quot;Zscore&quot; &lt;= -1.96 AND &quot;Zscore&quot; > -2.58 AND &quot;pvalue&quot; &lt;= 0.05 AND &quot;pvalue&quot; > 0.01" symbol="1"/>
      <rule label="coldspot 90% confidence" key="{4db48ebb-7475-4b80-a367-ea34a046b037}" filter="&quot;Zscore&quot; &lt;= -1.65 AND &quot;Zscore&quot; > -1.96 AND &quot;pvalue&quot; &lt;= 0.1 AND &quot;pvalue&quot; > 0.05" symbol="2"/>
      <rule label="not significant" key="{7f29558c-fd89-4a76-a23c-742c22fb6be2}" filter="&quot;Zscore&quot; > -1.65 AND &quot;Zscore&quot; &lt; 1.65 AND &quot;pvalue&quot; > 0.1" symbol="3"/>
      <rule label="hotspot 90% confidence" key="{e207b7c2-d812-4614-8934-8efaed7e5c83}" filter="&quot;Zscore&quot; >= 1.65 AND &quot;Zscore&quot; &lt; 1.96 AND &quot;pvalue&quot; &lt;= 0.1 AND &quot;pvalue&quot; > 0.05" symbol="4"/>
      <rule label="hotspot 95% confidence" key="{2047f641-3f1b-43e5-bbbc-acdf4f66c7d8}" filter="&quot;Zscore&quot; >= 1.96 AND &quot;Zscore&quot; &lt; 2.58 AND &quot;pvalue&quot; &lt;= 0.05 AND &quot;pvalue&quot; > 0.01" symbol="5"/>
      <rule label="hotspot 99% confidence" key="{656bbd4e-43b1-431c-bfe2-2e4d316a7cdc}" filter="&quot;Zscore&quot; >= 2.58 AND &quot;pvalue&quot; &lt;= 0.01" symbol="6"/>
    </rules>
    <symbols>
      <symbol type="marker" alpha="1" clip_to_extent="1" name="0" force_rhr="0">
        <layer pass="0" enabled="1" locked="0" class="SimpleMarker">
          <prop k="angle" v="0"/>
          <prop k="color" v="31,120,180,255"/>
          <prop k="horizontal_anchor_point" v="1"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="name" v="circle"/>
          <prop k="offset" v="0,0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="outline_color" v="0,0,0,255"/>
          <prop k="outline_style" v="solid"/>
          <prop k="outline_width" v="0"/>
          <prop k="outline_width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="outline_width_unit" v="MM"/>
          <prop k="scale_method" v="diameter"/>
          <prop k="size" v="2.6"/>
          <prop k="size_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="size_unit" v="MM"/>
          <prop k="vertical_anchor_point" v="1"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol type="marker" alpha="1" clip_to_extent="1" name="1" force_rhr="0">
        <layer pass="0" enabled="1" locked="0" class="SimpleMarker">
          <prop k="angle" v="0"/>
          <prop k="color" v="38,187,219,255"/>
          <prop k="horizontal_anchor_point" v="1"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="name" v="circle"/>
          <prop k="offset" v="0,0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="outline_color" v="0,0,0,255"/>
          <prop k="outline_style" v="solid"/>
          <prop k="outline_width" v="0"/>
          <prop k="outline_width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="outline_width_unit" v="MM"/>
          <prop k="scale_method" v="diameter"/>
          <prop k="size" v="2.2"/>
          <prop k="size_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="size_unit" v="MM"/>
          <prop k="vertical_anchor_point" v="1"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol type="marker" alpha="1" clip_to_extent="1" name="2" force_rhr="0">
        <layer pass="0" enabled="1" locked="0" class="SimpleMarker">
          <prop k="angle" v="0"/>
          <prop k="color" v="146,255,225,255"/>
          <prop k="horizontal_anchor_point" v="1"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="name" v="circle"/>
          <prop k="offset" v="0,0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="outline_color" v="0,0,0,255"/>
          <prop k="outline_style" v="solid"/>
          <prop k="outline_width" v="0"/>
          <prop k="outline_width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="outline_width_unit" v="MM"/>
          <prop k="scale_method" v="diameter"/>
          <prop k="size" v="2"/>
          <prop k="size_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="size_unit" v="MM"/>
          <prop k="vertical_anchor_point" v="1"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol type="marker" alpha="1" clip_to_extent="1" name="3" force_rhr="0">
        <layer pass="0" enabled="1" locked="0" class="SimpleMarker">
          <prop k="angle" v="0"/>
          <prop k="color" v="0,0,0,0"/>
          <prop k="horizontal_anchor_point" v="1"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="name" v="circle"/>
          <prop k="offset" v="0,0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="outline_color" v="0,0,0,255"/>
          <prop k="outline_style" v="solid"/>
          <prop k="outline_width" v="0"/>
          <prop k="outline_width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="outline_width_unit" v="MM"/>
          <prop k="scale_method" v="diameter"/>
          <prop k="size" v="1.4"/>
          <prop k="size_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="size_unit" v="MM"/>
          <prop k="vertical_anchor_point" v="1"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol type="marker" alpha="1" clip_to_extent="1" name="4" force_rhr="0">
        <layer pass="0" enabled="1" locked="0" class="SimpleMarker">
          <prop k="angle" v="0"/>
          <prop k="color" v="234,215,40,255"/>
          <prop k="horizontal_anchor_point" v="1"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="name" v="circle"/>
          <prop k="offset" v="0,0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="outline_color" v="0,0,0,255"/>
          <prop k="outline_style" v="solid"/>
          <prop k="outline_width" v="0"/>
          <prop k="outline_width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="outline_width_unit" v="MM"/>
          <prop k="scale_method" v="diameter"/>
          <prop k="size" v="2"/>
          <prop k="size_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="size_unit" v="MM"/>
          <prop k="vertical_anchor_point" v="1"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol type="marker" alpha="1" clip_to_extent="1" name="5" force_rhr="0">
        <layer pass="0" enabled="1" locked="0" class="SimpleMarker">
          <prop k="angle" v="0"/>
          <prop k="color" v="253,110,92,255"/>
          <prop k="horizontal_anchor_point" v="1"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="name" v="circle"/>
          <prop k="offset" v="0,0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="outline_color" v="0,0,0,255"/>
          <prop k="outline_style" v="solid"/>
          <prop k="outline_width" v="0"/>
          <prop k="outline_width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="outline_width_unit" v="MM"/>
          <prop k="scale_method" v="diameter"/>
          <prop k="size" v="2.2"/>
          <prop k="size_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="size_unit" v="MM"/>
          <prop k="vertical_anchor_point" v="1"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol type="marker" alpha="1" clip_to_extent="1" name="6" force_rhr="0">
        <layer pass="0" enabled="1" locked="0" class="SimpleMarker">
          <prop k="angle" v="0"/>
          <prop k="color" v="203,26,0,255"/>
          <prop k="horizontal_anchor_point" v="1"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="name" v="circle"/>
          <prop k="offset" v="0,0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="outline_color" v="0,0,0,255"/>
          <prop k="outline_style" v="solid"/>
          <prop k="outline_width" v="0"/>
          <prop k="outline_width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="outline_width_unit" v="MM"/>
          <prop k="scale_method" v="diameter"/>
          <prop k="size" v="2.6"/>
          <prop k="size_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="size_unit" v="MM"/>
          <prop k="vertical_anchor_point" v="1"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
    </symbols>
  </renderer-v2>
  <customproperties>
    <property key="embeddedWidgets/count" value="0"/>
    <property key="variableNames"/>
    <property key="variableValues"/>
  </customproperties>
  <blendMode>0</blendMode>
  <featureBlendMode>0</featureBlendMode>
  <layerOpacity>1</layerOpacity>
  <SingleCategoryDiagramRenderer attributeLegend="1" diagramType="Pie">
    <DiagramCategory backgroundColor="#ffffff" penColor="#000000" scaleDependency="Area" barWidth="5" width="15" lineSizeType="MM" sizeScale="3x:0,0,0,0,0,0" maxScaleDenominator="1e+08" enabled="0" lineSizeScale="3x:0,0,0,0,0,0" backgroundAlpha="255" opacity="1" penAlpha="255" labelPlacementMethod="XHeight" height="15" rotationOffset="270" penWidth="0" scaleBasedVisibility="0" diagramOrientation="Up" minScaleDenominator="0" minimumSize="0" sizeType="MM">
      <fontProperties style="" description="MS Shell Dlg 2,8.25,-1,5,50,0,0,0,0,0"/>
      <attribute label="" color="#000000" field=""/>
    </DiagramCategory>
  </SingleCategoryDiagramRenderer>
  <DiagramLayerSettings showAll="1" obstacle="0" placement="0" linePlacementFlags="2" priority="0" dist="0" zIndex="0">
    <properties>
      <Option type="Map">
        <Option type="QString" name="name" value=""/>
        <Option name="properties"/>
        <Option type="QString" name="type" value="collection"/>
      </Option>
    </properties>
  </DiagramLayerSettings>
  <geometryOptions removeDuplicateNodes="0" geometryPrecision="0">
    <activeChecks/>
    <checkConfiguration/>
  </geometryOptions>
  <fieldConfiguration>
    <field name="level3">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="level4">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="level5">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="level6">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="level7">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="uid">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="TLD_PERC">
      <editWidget type="Range">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="Zscore">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="pvalue">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="LONG">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="LAT">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="HS_Output">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias name="" index="0" field="level3"/>
    <alias name="" index="1" field="level4"/>
    <alias name="" index="2" field="level5"/>
    <alias name="" index="3" field="level6"/>
    <alias name="" index="4" field="level7"/>
    <alias name="" index="5" field="uid"/>
    <alias name="" index="6" field="TLD_PERC"/>
    <alias name="" index="7" field="Zscore"/>
    <alias name="" index="8" field="pvalue"/>
    <alias name="" index="9" field="LONG"/>
    <alias name="" index="10" field="LAT"/>
    <alias name="" index="11" field="HS_Output"/>
  </aliases>
  <excludeAttributesWMS/>
  <excludeAttributesWFS/>
  <defaults>
    <default expression="" applyOnUpdate="0" field="level3"/>
    <default expression="" applyOnUpdate="0" field="level4"/>
    <default expression="" applyOnUpdate="0" field="level5"/>
    <default expression="" applyOnUpdate="0" field="level6"/>
    <default expression="" applyOnUpdate="0" field="level7"/>
    <default expression="" applyOnUpdate="0" field="uid"/>
    <default expression="" applyOnUpdate="0" field="TLD_PERC"/>
    <default expression="" applyOnUpdate="0" field="Zscore"/>
    <default expression="" applyOnUpdate="0" field="pvalue"/>
    <default expression="" applyOnUpdate="0" field="LONG"/>
    <default expression="" applyOnUpdate="0" field="LAT"/>
    <default expression="" applyOnUpdate="0" field="HS_Output"/>
  </defaults>
  <constraints>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" field="level3" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" field="level4" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" field="level5" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" field="level6" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" field="level7" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" field="uid" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" field="TLD_PERC" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" field="Zscore" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" field="pvalue" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" field="LONG" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" field="LAT" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" field="HS_Output" unique_strength="0"/>
  </constraints>
  <constraintExpressions>
    <constraint exp="" desc="" field="level3"/>
    <constraint exp="" desc="" field="level4"/>
    <constraint exp="" desc="" field="level5"/>
    <constraint exp="" desc="" field="level6"/>
    <constraint exp="" desc="" field="level7"/>
    <constraint exp="" desc="" field="uid"/>
    <constraint exp="" desc="" field="TLD_PERC"/>
    <constraint exp="" desc="" field="Zscore"/>
    <constraint exp="" desc="" field="pvalue"/>
    <constraint exp="" desc="" field="LONG"/>
    <constraint exp="" desc="" field="LAT"/>
    <constraint exp="" desc="" field="HS_Output"/>
  </constraintExpressions>
  <expressionfields/>
  <attributeactions>
    <defaultAction key="Canvas" value="{00000000-0000-0000-0000-000000000000}"/>
  </attributeactions>
  <attributetableconfig sortExpression="" sortOrder="0" actionWidgetStyle="dropDown">
    <columns>
      <column type="field" hidden="0" name="level3" width="-1"/>
      <column type="field" hidden="0" name="level4" width="-1"/>
      <column type="field" hidden="0" name="level5" width="-1"/>
      <column type="field" hidden="0" name="level6" width="-1"/>
      <column type="field" hidden="0" name="level7" width="-1"/>
      <column type="field" hidden="0" name="uid" width="-1"/>
      <column type="field" hidden="0" name="TLD_PERC" width="-1"/>
      <column type="field" hidden="0" name="Zscore" width="-1"/>
      <column type="field" hidden="0" name="pvalue" width="-1"/>
      <column type="field" hidden="0" name="LONG" width="-1"/>
      <column type="field" hidden="0" name="LAT" width="-1"/>
      <column type="field" hidden="0" name="HS_Output" width="-1"/>
      <column type="actions" hidden="1" width="-1"/>
    </columns>
  </attributetableconfig>
  <conditionalstyles>
    <rowstyles/>
    <fieldstyles/>
  </conditionalstyles>
  <editform tolerant="1"></editform>
  <editforminit/>
  <editforminitcodesource>0</editforminitcodesource>
  <editforminitfilepath></editforminitfilepath>
  <editforminitcode><![CDATA[# -*- coding: utf-8 -*-
"""
QGIS forms can have a Python function that is called when the form is
opened.

Use this function to add extra logic to your forms.

Enter the name of the function in the "Python Init function"
field.
An example follows:
"""
from PyQt4.QtGui import QWidget

def my_form_open(dialog, layer, feature):
	geom = feature.geometry()
	control = dialog.findChild(QWidget, "MyLineEdit")
]]></editforminitcode>
  <featformsuppress>0</featformsuppress>
  <editorlayout>generatedlayout</editorlayout>
  <editable>
    <field name="HS_Output" editable="1"/>
    <field name="LAT" editable="1"/>
    <field name="LONG" editable="1"/>
    <field name="TLD_PERC" editable="1"/>
    <field name="Zscore" editable="1"/>
    <field name="level3" editable="1"/>
    <field name="level4" editable="1"/>
    <field name="level5" editable="1"/>
    <field name="level6" editable="1"/>
    <field name="level7" editable="1"/>
    <field name="pvalue" editable="1"/>
    <field name="uid" editable="1"/>
  </editable>
  <labelOnTop>
    <field name="HS_Output" labelOnTop="0"/>
    <field name="LAT" labelOnTop="0"/>
    <field name="LONG" labelOnTop="0"/>
    <field name="TLD_PERC" labelOnTop="0"/>
    <field name="Zscore" labelOnTop="0"/>
    <field name="level3" labelOnTop="0"/>
    <field name="level4" labelOnTop="0"/>
    <field name="level5" labelOnTop="0"/>
    <field name="level6" labelOnTop="0"/>
    <field name="level7" labelOnTop="0"/>
    <field name="pvalue" labelOnTop="0"/>
    <field name="uid" labelOnTop="0"/>
  </labelOnTop>
  <widgets/>
  <previewExpression>uid</previewExpression>
  <mapTip>NAME_COM</mapTip>
  <layerGeometryType>0</layerGeometryType>
</qgis>
