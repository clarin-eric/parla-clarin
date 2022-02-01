# Validate 
all:	val-schema xml-schemas val-examples html

# Parla-CLARIN TEI documentation and schema
SCHEMA = ../Schema/parla-clarin-odd.xml

# The infamous TEI P5 subset from the Guidelines
SUBSET = --localsource=p5subset.xml
#SUBSET = --localsource=https://tei-c.org/release/xml/tei/odd/p5subset.xml

# Location and directory name of the profile for conversion to HTML
PROFILE = --profiledir=$(shell pwd) --profile=profile

# Convert to HTML
html:	val-schema
	Stylesheets/bin/teitohtml ${PROFILE} --odd ${SUBSET} ${OUTPUT} ${SCHEMA} ../docs/index.html

# Compile schemas to RelaxNG, DTD and XSD; best use the RelaxNG one.
xml-schemas:	val-schema
	Stylesheets/bin/teitorelaxng    ${SUBSET} ${SCHEMA} ../Schema/parla-clarin.rng
	Stylesheets/bin/teitornc        ${SUBSET} ${SCHEMA} ../Schema/parla-clarin.rnc
	Stylesheets/bin/teitodtd        ${SUBSET} ${SCHEMA} ../Schema/parla-clarin.dtd
	Stylesheets/bin/teitoxsd        ${SUBSET} ${SCHEMA} ../Schema/parla-clarin.xsd
	Stylesheets/bin/teitoschematron ${SUBSET} ${SCHEMA} ../Schema/parla-clarin.sch

val:	val-schema val-examples
val-schema:
	$j tei_odds.rng ../Schema/parla-clarin-odd.xml

# Validate examples
val-examples:
	$j ../Schema/parla-clarin.rng ../Examples/Parla-CLARIN-Exemplar.xml
	$j ../Schema/parla-clarin.rng ../Examples/AkomaNtosoCL-Example.xml
	$j ../Schema/parla-clarin.rng ../Examples/AkomaNtosoKE-Example.xml
	$j ../Schema/parla-clarin.rng ../Examples/slovParl2.0/teiCorpus.xml
	xmllint --xinclude ../Examples/siParl2.0/siParl.tei/siParl-sample.xml | $j ../Schema/parla-clarin.rng
	xmllint --xinclude ../Examples/siParl2.0/siParl.tei/SDT2-sample.xml | $j ../Schema/parla-clarin.rng
	xmllint --xinclude ../Examples/siParl2.0/siParl.ana/siParl-ana-sample.xml | $j ../Schema/parla-clarin.rng
	xmllint --xinclude ../Examples/siParl2.0/siParl.ana/SDT2-ana-sample.xml | $j ../Schema/parla-clarin.rng
### Add ParlaMint!

### Location of Jing (for RelaxNG validation) and Saxon (for XSLT stylesheets)
j = java -jar /usr/share/java/jing.jar
s = java -jar /usr/share/java/saxon.jar
