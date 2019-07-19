all:	schemas html
# Have to have local source of p5subset, as my Java is too old to fetch it with https!
PARAMS = --localsource=p5subset.xml ../Schema/parla-clarin-odd.xml
schemas:
	Stylesheets/bin/teitorelaxng    ${PARAMS} ../Schema/parla-clarin.rng
	Stylesheets/bin/teitornc        ${PARAMS} ../Schema/parla-clarin.rnc
	Stylesheets/bin/teitodtd        ${PARAMS} ../Schema/parla-clarin.dtd
	Stylesheets/bin/teitoxsd        ${PARAMS} ../Schema/parla-clarin.xsd
	Stylesheets/bin/teitoschematron ${PARAMS} ../Schema/parla-clarin.sch
H = /home/tomaz/Resources/CLARIN/DARIAH-SI/Parla-CLARIN/parla-clarin/bin
html:
	Stylesheets/bin/teitohtml --profiledir=$H --profile=profile --odd ${PARAMS} ../docs/index.html

#s = java -jar ~/bin/saxon9he.jar
#s = java -jar /usr/local/bin/saxon9he.jar
s = java -Djavax.xml.parsers.DocumentBuilderFactory=org.apache.xerces.jaxp.DocumentBuilderFactoryImpl -Djavax.xml.parsers.SAXParserFactory=org.apache.xerces.jaxp.SAXParserFactoryImpl net.sf.saxon.Transform

