.PHONY: all clean mysql data resources dependencies variation annotation genome genome-index pip bowtie zippy-venv zippy-package run uninstall

# could be tested like this: make ZIPPYPATH=$PWD
ZIPPYPATH=/var/local/zippy

all: dependencies install resources run

resources: annotation genome genome-index

annotation: $(ZIPPYPATH)/resources/refGene variation
 
variation: $(ZIPPYPATH)/resources/00-common_all.vcf.gz $(ZIPPYPATH)/resources/00-common_all.vcf.gz.tbi

$(ZIPPYPATH)/resources/00-common_all.vcf.gz:
	mkdir -p $(ZIPPYPATH)/resources
	@echo "Downloading variation..."
	@curl -Lo $@ https://ftp.ncbi.nlm.nih.gov/snp/organisms/human_9606_b151_GRCh37p13/VCF/00-common_all.vcf.gz
	@echo "Ok"

$(ZIPPYPATH)/resources/00-common_all.vcf.gz.tbi:
	mkdir -p $(ZIPPYPATH)/resources
	@echo "Downloading variation index..."
	@curl -Lo $@ https://ftp.ncbi.nlm.nih.gov/snp/organisms/human_9606_b151_GRCh37p13/VCF/00-common_all.vcf.gz.tbi
	@echo "Ok"

$(ZIPPYPATH)/resources/refGene:
	mkdir -p $(ZIPPYPATH)/resources
	@echo "Downloading refGene..."
	@mysql --user=genome --host=genome-mysql.cse.ucsc.edu -A -N -D hg19 -P 3306 \
	 -e "SELECT DISTINCT r.bin,CONCAT(r.name,'.',i.version),c.ensembl,r.strand, r.txStart,r.txEnd,r.cdsStart,r.cdsEnd,r.exonCount,r.exonStarts,r.exonEnds,r.score,r.name2,r.cdsStartStat,r.cdsEndStat,r.exonFrames FROM refGene as r, hgFixed.gbCdnaInfo as i, ucscToEnsembl as c WHERE r.name=i.acc AND c.ucsc = r.chrom ORDER BY r.bin;" > $@
	@echo "Ok"

genome-index: bowtie $(ZIPPYPATH)/resources/human_g1k_v37.bowtie.1.bt2

$(ZIPPYPATH)/resources/human_g1k_v37.bowtie.%: $(ZIPPYPATH)/resources/human_g1k_v37.fasta $(ZIPPYPATH)/resources/human_g1k_v37.fasta.fai
	@echo "Bowtieing genome..."
	@bowtie2-build human_g1k_v37.fasta human_g1k_v37.bowtie
	@echo "Ok"

genome: $(ZIPPYPATH)/resources/human_g1k_v37.fasta $(ZIPPYPATH)/resources/human_g1k_v37.fasta.fai

$(ZIPPYPATH)/resources/human_g1k_v37.fasta:
	mkdir -p resources
	@echo "Downloading genome..."
	@curl -Ls http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/human_g1k_v37.fasta.gz | gunzip -c > $@
	@echo "Ok"

$(ZIPPYPATH)/resources/human_g1k_v37.fasta.fai:
	mkdir -p resources
	@echo "Downloading genome index..."
	@curl -Lo $@ http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/human_g1k_v37.fasta.fai
	@echo "Ok"

pip: /usr/bin/pip

# Should be run as root
/usr/bin/pip:
	curl -Ls https://bootstrap.pypa.io/get-pip.py | python

bowtie: /usr/local/bin/bowtie2-build

# Should be run as root
/usr/local/bin/bowtie2-build:
	curl -Lo /tmp/bowtie2-2.3.4.2-linux-x86_64.zip \
		https://newcontinuum.dl.sourceforge.net/project/bowtie-bio/bowtie2/2.3.4.2/bowtie2-2.3.4.2-linux-x86_64.zip
	cd /tmp/ && \
	unzip bowtie2-2.3.4.2-linux-x86_64.zip && \
	mv bowtie2-2.3.4.2-linux-x86_64/bowtie2* /usr/local/bin/ && \
	rm -rf bowtie2-2.3.4.2*

packages:
	yum -y install epel-release
	yum -y install make gcc python-devel unzip zlib-devel perl mysql supervisor

dependencies: packages bowtie

/usr/bin/virtualenv: /usr/bin/pip
	pip install virtualenv

$(ZIPPYPATH)/venv: /usr/bin/virtualenv
	virtualenv $@
	$(ZIPPYPATH)/venv/bin/pip install Cython

zippy-venv: $(ZIPPYPATH)/venv

zippy-package: zippy-venv 
	$(ZIPPYPATH)/venv/bin/pip install .

$(ZIPPYPATH)/zippy.json: zippy-package
	ln -s $(ZIPPYPATH)/venv/lib/python2.7/site-packages/zippy/zippy.json $@ || true

install: zippy-venv zippy-package $(ZIPPYPATH)/zippy.json
	$(ZIPPYPATH)/venv/bin/pip install gunicorn
	mkdir -p $(ZIPPYPATH)/{resources,uploads,results}
	touch $(ZIPPYPATH)/{zippy.sqlite,zippy.log,.blacklist.cache}
	# Register systemd service
	grep -q ^zippy: /etc/group || groupadd zippy
	grep -q ^zippy: /etc/passwd || useradd -rMg zippy zippy
	cp install/zippy.service /etc/systemd/system/zippy.service
	systemctl daemon-reload

uninstall:
	systemctl stop zippy || true
	systemctl stop zippy || true
	rm /etc/systemd/system/zippy.service || true
	userdel zippy || true
	groupdel zippy || true
	rm -r ${ZIPPYPATH} || true

run:
	# Start
	systemctl start zippy
	# Start on Boot
	systemctl enable zippy
