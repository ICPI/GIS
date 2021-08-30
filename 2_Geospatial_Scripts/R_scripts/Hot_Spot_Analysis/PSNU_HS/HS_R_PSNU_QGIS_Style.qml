<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis version="3.8.0-Zanzibar" hasScaleBasedVisibilityFlag="0" maxScale="0" simplifyMaxScale="1" styleCategories="AllStyleCategories" simplifyDrawingHints="1" simplifyDrawingTol="1" labelsEnabled="0" simplifyAlgorithm="0" minScale="1e+08" simplifyLocal="1" readOnly="0">
  <flags>
    <Identifiable>1</Identifiable>
    <Removable>1</Removable>
    <Searchable>1</Searchable>
  </flags>
  <renderer-v2 symbollevels="0" forceraster="0" type="RuleRenderer" enableorderby="0">
    <rules key="{3a3ff373-1818-43ae-b0b4-d20c56fe6c15}">
      <rule label="coldspot 99% confidence" key="{9e8653b9-1099-42cb-b094-3fe22a3f3934}" filter="&quot;Zscore&quot; &lt;= -2.58 AND &quot;pvalue&quot; &lt;= 0.01" symbol="0"/>
      <rule label="coldspot 95% confidence" key="{f6f2398d-58c7-465e-9329-6bb724a90450}" filter="&quot;Zscore&quot; &lt;= -1.96 AND &quot;Zscore&quot; > -2.58 AND &quot;pvalue&quot; &lt;= 0.05 AND &quot;pvalue&quot; > 0.01" symbol="1"/>
      <rule label="coldspot 90% confidence " key="{5d7b8831-db8f-4604-b503-47bf62d9afb0}" filter="&quot;Zscore&quot; &lt;= -1.65 AND &quot;Zscore&quot; > -1.96 AND &quot;pvalue&quot; &lt;= 0.1 AND &quot;pvalue&quot; > 0.05" symbol="2"/>
      <rule label="not significant" key="{8b49b417-59e0-4535-ab53-f24d0b12f2f2}" filter="&quot;Zscore&quot; > -1.65 AND &quot;Zscore&quot; &lt; 1.65 AND &quot;pvalue&quot; > 0.1" symbol="3"/>
      <rule label="hotspot 90% confidence" key="{129fdaf0-52bd-4c05-87de-047a4598b835}" filter="&quot;Zscore&quot; >= 1.65 AND &quot;Zscore&quot; &lt; 1.96 AND &quot;pvalue&quot; &lt;= 0.1 AND &quot;pvalue&quot; > 0.05" symbol="4"/>
      <rule label="hotspot 95% confidence" key="{f0c53df9-275b-4d1d-a683-30a78480314f}" filter="&quot;Zscore&quot; >= 1.96 AND &quot;Zscore&quot; &lt; 2.58 AND &quot;pvalue&quot; &lt;= 0.05 AND &quot;pvalue&quot; > 0.01" symbol="5"/>
      <rule label="hotspot 99% confidence" key="{4f048732-25cc-48d0-92a1-9e6cef8dc98d}" filter="&quot;Zscore&quot; >= 2.58 AND &quot;pvalue&quot; &lt;= 0.01" symbol="6"/>
    </rules>
    <symbols>
      <symbol type="fill" alpha="1" clip_to_extent="1" name="0" force_rhr="0">
        <layer pass="0" enabled="1" locked="0" class="SimpleFill">
          <prop k="border_width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="color" v="31,120,180,255"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="offset" v="0,0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="outline_color" v="35,35,35,255"/>
          <prop k="outline_style" v="solid"/>
          <prop k="outline_width" v="0.26"/>
          <prop k="outline_width_unit" v="MM"/>
          <prop k="style" v="solid"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol type="fill" alpha="1" clip_to_extent="1" name="1" force_rhr="0">
        <layer pass="0" enabled="1" locked="0" class="SimpleFill">
          <prop k="border_width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="color" v="38,187,219,255"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="offset" v="0,0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="outline_color" v="35,35,35,255"/>
          <prop k="outline_style" v="solid"/>
          <prop k="outline_width" v="0.26"/>
          <prop k="outline_width_unit" v="MM"/>
          <prop k="style" v="solid"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol type="fill" alpha="1" clip_to_extent="1" name="2" force_rhr="0">
        <layer pass="0" enabled="1" locked="0" class="SimpleFill">
          <prop k="border_width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="color" v="146,255,225,255"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="offset" v="0,0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="outline_color" v="35,35,35,255"/>
          <prop k="outline_style" v="solid"/>
          <prop k="outline_width" v="0.26"/>
          <prop k="outline_width_unit" v="MM"/>
          <prop k="style" v="solid"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol type="fill" alpha="1" clip_to_extent="1" name="3" force_rhr="0">
        <layer pass="0" enabled="1" locked="0" class="SimpleFill">
          <prop k="border_width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="color" v="190,207,80,0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="offset" v="0,0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="outline_color" v="35,35,35,255"/>
          <prop k="outline_style" v="solid"/>
          <prop k="outline_width" v="0.26"/>
          <prop k="outline_width_unit" v="MM"/>
          <prop k="style" v="solid"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol type="fill" alpha="1" clip_to_extent="1" name="4" force_rhr="0">
        <layer pass="0" enabled="1" locked="0" class="SimpleFill">
          <prop k="border_width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="color" v="234,215,40,255"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="offset" v="0,0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="outline_color" v="35,35,35,255"/>
          <prop k="outline_style" v="solid"/>
          <prop k="outline_width" v="0.26"/>
          <prop k="outline_width_unit" v="MM"/>
          <prop k="style" v="solid"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol type="fill" alpha="1" clip_to_extent="1" name="5" force_rhr="0">
        <layer pass="0" enabled="1" locked="0" class="SimpleFill">
          <prop k="border_width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="color" v="253,110,92,255"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="offset" v="0,0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="outline_color" v="35,35,35,255"/>
          <prop k="outline_style" v="solid"/>
          <prop k="outline_width" v="0.26"/>
          <prop k="outline_width_unit" v="MM"/>
          <prop k="style" v="solid"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol type="fill" alpha="1" clip_to_extent="1" name="6" force_rhr="0">
        <layer pass="0" enabled="1" locked="0" class="SimpleFill">
          <prop k="border_width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="color" v="203,26,0,206"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="offset" v="0,0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="outline_color" v="35,35,35,255"/>
          <prop k="outline_style" v="solid"/>
          <prop k="outline_width" v="0.26"/>
          <prop k="outline_width_unit" v="MM"/>
          <prop k="style" v="solid"/>
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
  <SingleCategoryDiagramRenderer attributeLegend="1" diagramType="Histogram">
    <DiagramCategory backgroundColor="#ffffff" penColor="#000000" scaleDependency="Area" barWidth="5" width="15" lineSizeType="MM" sizeScale="3x:0,0,0,0,0,0" maxScaleDenominator="1e+08" enabled="0" lineSizeScale="3x:0,0,0,0,0,0" backgroundAlpha="255" opacity="1" penAlpha="255" labelPlacementMethod="XHeight" height="15" rotationOffset="270" penWidth="0" scaleBasedVisibility="0" diagramOrientation="Up" minScaleDenominator="0" minimumSize="0" sizeType="MM">
      <fontProperties style="" description="MS Shell Dlg 2,8.25,-1,5,50,0,0,0,0,0"/>
    </DiagramCategory>
  </SingleCategoryDiagramRenderer>
  <DiagramLayerSettings showAll="1" obstacle="0" placement="1" linePlacementFlags="18" priority="0" dist="0" zIndex="0">
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
    <alias name="" index="3" field="uid"/>
    <alias name="" index="4" field="TLD_PERC"/>
    <alias name="" index="5" field="Zscore"/>
    <alias name="" index="6" field="pvalue"/>
    <alias name="" index="7" field="HS_Output"/>
  </aliases>
  <excludeAttributesWMS/>
  <excludeAttributesWFS/>
  <defaults>
    <default expression="" applyOnUpdate="0" field="level3"/>
    <default expression="" applyOnUpdate="0" field="level4"/>
    <default expression="" applyOnUpdate="0" field="level5"/>
    <default expression="" applyOnUpdate="0" field="uid"/>
    <default expression="" applyOnUpdate="0" field="TLD_PERC"/>
    <default expression="" applyOnUpdate="0" field="Zscore"/>
    <default expression="" applyOnUpdate="0" field="pvalue"/>
    <default expression="" applyOnUpdate="0" field="HS_Output"/>
  </defaults>
  <constraints>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" field="level3" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" field="level4" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" field="level5" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" field="uid" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" field="TLD_PERC" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" field="Zscore" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" field="pvalue" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" field="HS_Output" unique_strength="0"/>
  </constraints>
  <constraintExpressions>
    <constraint exp="" desc="" field="level3"/>
    <constraint exp="" desc="" field="level4"/>
    <constraint exp="" desc="" field="level5"/>
    <constraint exp="" desc="" field="uid"/>
    <constraint exp="" desc="" field="TLD_PERC"/>
    <constraint exp="" desc="" field="Zscore"/>
    <constraint exp="" desc="" field="pvalue"/>
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
      <column type="field" hidden="0" name="uid" width="-1"/>
      <column type="field" hidden="0" name="TLD_PERC" width="-1"/>
      <column type="field" hidden="0" name="Zscore" width="-1"/>
      <column type="field" hidden="0" name="pvalue" width="-1"/>
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
from qgis.PyQt.QtWidgets import QWidget

def my_form_open(dialog, layer, feature):
	geom = feature.geometry()
	control = dialog.findChild(QWidget, "MyLineEdit")
]]></editforminitcode>
  <featformsuppress>0</featformsuppress>
  <editorlayout>generatedlayout</editorlayout>
  <editable>
    <field name="HS_Output" editable="1"/>
    <field name="TLD_PERC" editable="1"/>
    <field name="Zscore" editable="1"/>
    <field name="level3" editable="1"/>
    <field name="level4" editable="1"/>
    <field name="level5" editable="1"/>
    <field name="pvalue" editable="1"/>
    <field name="uid" editable="1"/>
  </editable>
  <labelOnTop>
    <field name="HS_Output" labelOnTop="0"/>
    <field name="TLD_PERC" labelOnTop="0"/>
    <field name="Zscore" labelOnTop="0"/>
    <field name="level3" labelOnTop="0"/>
    <field name="level4" labelOnTop="0"/>
    <field name="level5" labelOnTop="0"/>
    <field name="pvalue" labelOnTop="0"/>
    <field name="uid" labelOnTop="0"/>
  </labelOnTop>
  <widgets/>
  <previewExpression>uid</previewExpression>
  <mapTip></mapTip>
  <layerGeometryType>2</layerGeometryType>
</qgis>
