# SchoolTesting
XSL Library for RenderX XEP PDF Form generation

This is a set of XSLs for RenderX-extension specific implementaton of PDF Forms. 

They were designed for school testing, mapping things like multiple choice questions like the following to PDF Form option-group.

              <item>
                    <checkbox name="q2" value="false" readonly="true"
                        calculate="optioncheck('q2','q2choice',5);"/>
                    <description>What are the single-stranded ends created by the cutting of piece
                        of DNA by a restriction enzyme called? <optiongroup name="q2choice">
                            <option name="q2_1" correct="true">Sticky ends</option>
                            <option name="q2_2">Base pairs</option>
                            <option name="q2_3">Tacky ends</option>
                            <option name="q2_4">Complementary ends</option>
                            <option name="q2_5">Restriction zones</option>
                        </optiongroup>
                    </description>
                </item>

The template supports checkbox, optiongroups, comboboxes, textboxes, multiline input and buttons.

They have some very advanced things including Javascript injection in the PDF and they even inject the source XML into hidden fields so that a test can be “scored” server side, flattened or even regenerated for the teacher to add comments in a different PDF form..

See also the generic example at https://github.com/kbrown01/Checklist
