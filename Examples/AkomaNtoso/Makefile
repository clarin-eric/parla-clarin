get:
	rm -f *.xsd
	rm -f *.xml
	#AKN xml.xsd is broken!
	#wget http://docs.oasis-open.org/legaldocml/akn-core/v1.0/os/part2-specs/schemas/xml.xsd
	wget https://www.w3.org/2004/10/xml.xsd
	wget http://docs.oasis-open.org/legaldocml/akn-core/v1.0/os/part2-specs/schemas/akomantoso30.xsd
	wget http://docs.oasis-open.org/legaldocml/akn-core/v1.0/os/part2-specs/examples/cl_Sesion56_2.xml
	xmllint --noout --schema akomantoso30.xsd cl_Sesion56_2.xml
	wget http://docs.oasis-open.org/legaldocml/akn-core/v1.0/os/part2-specs/examples/ke_Debate_Bungeni_2011-06-10.xml
	xmllint --noout --schema akomantoso30.xsd ke_Debate_Bungeni_2011-06-10.xml

s = java -jar /usr/local/bin/saxon9he.jar
j = java -jar /usr/local/bin/jing.jar
P = parallel --gnu --halt 2
