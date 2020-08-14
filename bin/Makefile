test:
	date
all:	schema val-exa html

val:	val-exa val-odd
val-exa:
	$j ../Schema/parla-clarin.rng ../Examples/Parla-CLARIN-Exemplar.xml
	$j ../Schema/parla-clarin.rng ../Examples/AkomaNtosoCL-Example.xml
	$j ../Schema/parla-clarin.rng ../Examples/AkomaNtosoKE-Example.xml
	$j ../Schema/parla-clarin.rng ../Examples/slovParl2.0/teiCorpus.xml
	xmllint --xinclude ../Examples/siParl2.0/siParl.tei/siParl-sample.xml | $j ../Schema/parla-clarin.rng
	xmllint --xinclude ../Examples/siParl2.0/siParl.tei/SDT2-sample.xml | $j ../Schema/parla-clarin.rng
	xmllint --xinclude ../Examples/siParl2.0/siParl.ana/siParl-ana-sample.xml | $j ../Schema/parla-clarin.rng
	xmllint --xinclude ../Examples/siParl2.0/siParl.ana/SDT2-ana-sample.xml | $j ../Schema/parla-clarin.rng
val-odd:
	$j tei_odds.rng ../Schema/parla-clarin-odd.xml

# Have to have local source of p5subset, as my Java is too old to fetch it with https!
PARAMS = --localsource=p5subset.xml ../Schema/parla-clarin-odd.xml
schema:	val-odd
	Stylesheets/bin/teitorelaxng    ${PARAMS} ../Schema/parla-clarin.rng
	Stylesheets/bin/teitornc        ${PARAMS} ../Schema/parla-clarin.rnc
	Stylesheets/bin/teitodtd        ${PARAMS} ../Schema/parla-clarin.dtd
	Stylesheets/bin/teitoxsd        ${PARAMS} ../Schema/parla-clarin.xsd
	Stylesheets/bin/teitoschematron ${PARAMS} ../Schema/parla-clarin.sch
H = /home/tomaz/Resources/CLARIN/DARIAH-SI/Parla-CLARIN/parla-clarin/bin
html:	val-odd
	Stylesheets/bin/teitohtml --profiledir=$H --profile=profile --odd ${PARAMS} ../docs/index.html

j = java -jar /usr/local/bin/jing.jar
#s = java -jar ~/bin/saxon9he.jar
#s = java -jar /usr/local/bin/saxon9he.jar
s = java -Djavax.xml.parsers.DocumentBuilderFactory=org.apache.xerces.jaxp.DocumentBuilderFactoryImpl -Djavax.xml.parsers.SAXParserFactory=org.apache.xerces.jaxp.SAXParserFactoryImpl net.sf.saxon.Transform
