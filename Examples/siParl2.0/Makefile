all:	get sample conllu vert text meta
meta:
	rm -fr siParl.meta
	mkdir -p siParl.meta
	bin/siparl2meta.pl sessions ../siParl.ana/siParl-ana-sample.xml 'siParl.ana/SDT2/' siParl.meta
	bin/siparl2meta.pl speeches ../siParl.ana/siParl-ana-sample.xml 'siParl.ana/SDT2/' siParl.meta
text:
	rm -fr siParl.text
	mkdir -p siParl.text/SDT2;
	bin/tei2text.pl 'siParl.ana/*/*.xml' siParl.text
vert:
	rm -fr siParl.vert
	mkdir -p siParl.vert/SDT2
	cp ../../cqp/regi/siparl20 siParl.vert/siparl20.regi
	bin/parla-tei2vert.pl 'siParl.ana/*/*.xml' siParl.vert
	bin/joinvert.pl 'siParl.vert/*/*.vert' siParl.vert/siparl20-sample.vert
conllu:
	rm -fr siParl.conllu
	mkdir -p siParl.conllu/SDT2
	bin/teiud2conllu.pl 'siParl.ana/*/*.xml' siParl.conllu

sample:	sample-tei sample-ana
sample-ana:
	ls siParl.ana/S*/*.xml > files.ana.tmp
	$s files=../files.ana.tmp -xsl:bin/siparl2sample.xsl \
	siParl.ana/SDT2-ana.xml > siParl.ana/SDT2-ana-sample.xml
	$s -xi -xsl:bin/pretty.xsl siParl.ana/SDT2-ana-sample.xml | $j Schema/parla-clarin.rng
	$s files=../files.ana.tmp -xsl:bin/siparl2sample.xsl \
	siParl.ana/siParl-ana.xml > siParl.ana/siParl-ana-sample.xml
	$s -xi -xsl:bin/pretty.xsl siParl.ana/siParl-ana-sample.xml | $j Schema/parla-clarin.rng
	rm files.ana.tmp siParl.ana/siParl-ana.xml siParl.ana/SDT2-ana.xml
sample-tei:
	ls siParl.tei/S*/*.xml > files.tei.tmp
	$s files=../files.tei.tmp -xsl:bin/siparl2sample.xsl \
	siParl.tei/SDT2.xml > siParl.tei/SDT2-sample.xml
	$s -xi -xsl:bin/pretty.xsl siParl.tei/SDT2-sample.xml | $j Schema/parla-clarin.rng
	$s files=../files.tei.tmp -xsl:bin/siparl2sample.xsl \
	siParl.tei/siParl.xml > siParl.tei/siParl-sample.xml
	$s -xi -xsl:bin/pretty.xsl siParl.tei/siParl-sample.xml | $j Schema/parla-clarin.rng
	rm files.tei.tmp siParl.tei/siParl.xml siParl.tei/SDT2.xml
get:
	rm -fr siParl.tei
	mkdir -p siParl.tei/SDT2;
	cp ../../Pack/siParl-2.0.tei/SDT2/KPZONOJFSPD-Redna-021-1998-11-25.xml siParl.tei/SDT2
	cp ../../Pack/siParl-2.0.tei/SDT2/OZKGIP-Redna-025-1998-12-08.xml siParl.tei/SDT2
	cp ../../Pack/siParl-2.0.tei/SDT2/OZKSIS-Redna-034-2000-05-18.xml siParl.tei/SDT2
	cp ../../Pack/siParl-2.0.tei/SDT2.xml siParl.tei/
	cp ../../Pack/siParl-2.0.tei/siParl.xml siParl.tei/

	rm -fr siParl.ana
	mkdir -p siParl.ana/SDT2;
	cp ../../Master/SDT2/KPZONOJFSPD-Redna-021-1998-11-25-ana.xml siParl.ana/SDT2
	cp ../../Master/SDT2/OZKGIP-Redna-025-1998-12-08-ana.xml siParl.ana/SDT2
	cp ../../Master/SDT2/OZKSIS-Redna-034-2000-05-18-ana.xml siParl.ana/SDT2
	cp ../../Master/SDT2-ana.xml siParl.ana/
	cp ../../Master/siParl-ana.xml siParl.ana/

	cp ../../bin/siparl2sample.xsl bin/

	cp ../../bin/parla-tei2vert.pl bin/
	cp ../../bin/siparl2vert.xsl bin/
	cp ../../bin/parla-xml2vert.pl bin/
	cp ../../bin/joinvert.pl bin/

	cp ../../bin/tei2text.pl bin/
	cp ../../bin/teiana2txt.xsl bin/

	cp ../../bin/teiud2conllu.pl bin/
	cp ../../bin/teiud2conllu.xsl bin/

	cp ../../bin/siparl2meta.pl bin/
	cp ../../bin/siparl2meta.xsl bin/

j = java -jar /usr/local/bin/jing.jar 
#s = java -jar /usr/local/bin/saxon9he.jar
s = java -jar /home/tomaz/bin/saxon9he.jar
P = parallel --gnu --halt 2
