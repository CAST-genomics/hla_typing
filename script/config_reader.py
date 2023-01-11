"""Handles the config file reading and parameter setting."""


from typing import Dict, List
import yaml


def read_params(config_file:str)->Dict:
    """read config for bsub-specific configs"""
    with open(config_file, "r") as file:
        params = yaml.safe_load(file)
    return params


def get_params(config_yml:str="./examples/configs/basic_config_aou.yml")->List:
    """Grab params and pass back to main script."""    
    pars = read_params(config_yml)

    basepath = pars['basepath'] 
    refloc = pars['refloc'] 
    dirpath = pars['dirpath'] #"./output/"
    dirmanifest = pars['dirmanifest'] #basepath + "manifests/"
    manifest_file = pars['manifest_file'] #"2022-08-18-Shah-FFPE-DNA-Libs Info.xlsx"
    ncores = str(pars['ncores'])
    aou_cram = bool(pars['aou_cram']) # True
    logout = pars['logout'] #"/frazer01/home/aphodges/software/hpylori/examples/logs/combined_logs.out"
    logerr = pars['logerr'] #"/frazer01/home/aphodges/software/hpylori/examples/logs/combined_logs.err"
    script_path = pars['script_path']  # basepath + "/scripts/"
    outdir = pars['outpath'] # e.g. ./out/  .... add this manually

    #major inputs for files/refs/chr loc
    bed = pars['bed'] #"./hg38.bed"]  # bam = outpath + name + ".sam"
    #Target and local cram will be auto-generated from the manifest file for new selected columns.
    # target_cram = pars['target_cram']  #"gs://fc-aou-datasets-controlled/pooled/wgs/cram/v6_base/wgs_1000004.cram"
    # local_cram = dirpath + pars['local_cram']  #"wgs_1000004.cram"
    chr_loc = pars['chr_loc']  #"chr6"
    name = pars['script_name']  #"wgs_1000004_script.sh"

    fasta = pars['fasta'] #"./hg38.fa"
    refloc = fasta
    hlavbseq = pars['hlavbseq']  #"../../" + "HLAVBSeq.jar"
    jparam = pars['jparam'] #"-Xmx12G"
    process_hlas = pars['process_hlas']    #"./script/process_hla_types.R"
    allele = pars['allele']  #"./alleles.txt"
    mean_cov = pars['mean_cov'] #"5"
    read_len = pars['read_len'] #"151"
    
    return [basepath, refloc, dirpath, dirmanifest, manifest_file, \
    ncores, aou_cram, logout, logerr, script_path, outdir, \
	bed, chr_loc, name, fasta, refloc, hlavbseq, jparam, \
	process_hlas, allele, mean_cov, read_len]

