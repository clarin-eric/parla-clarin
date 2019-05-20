all:	schemas html
# Have to have local source of p5subset, as my Java is too old to fetch it with https!
PARAMS = --odd --localsource=p5subset.xml ../Schema/tei-parla-odd.xml
schemas:
	Stylesheets/bin/teitorelaxng ${PARAMS} ../Schema/tei-parla.rng
	Stylesheets/bin/teitornc     ${PARAMS} ../Schema/tei-parla.rnc
	Stylesheets/bin/teitodtd     ${PARAMS} ../Schema/tei-parla.dtd
	Stylesheets/bin/teitoxsd     ${PARAMS} ../Schema/tei-parla.xsd
html:
	$s -xsl:profile/html/to.xsl ../Schema/tei-parla-odd.xml > ../docs/parla-clarin.html

#s = java -jar ~/bin/saxon9he.jar
#s = java -jar /usr/local/bin/saxon9he.jar
s = java -Djavax.xml.parsers.DocumentBuilderFactory=org.apache.xerces.jaxp.DocumentBuilderFactoryImpl -Djavax.xml.parsers.SAXParserFactory=org.apache.xerces.jaxp.SAXParserFactoryImpl net.sf.saxon.Transform

