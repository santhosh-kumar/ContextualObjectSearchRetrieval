A multi-camera object search and retrieval algorithm using matlab.

This is a matlab implementation of the papers "Context-Aware Hypergraph Modeling for Re-identification and Summarization" published in Transactions of Multimedia and "Context-Aware Graph Modeling for Object Search and Retrieval in a Wide Area Camera Network" published in ICDSC'13.

Usage
------------

In order to run the algorithm, use the following command:

i) Run main.m: Generates the weight matrix and performs graph based query ranking.

iii) Run main_viper.m: Generates the weight matrix and performs association based ranking.

Data Processing
------------

i) Run scripts/generateTracklets.m to create tracklets for university bikepath dataset (generateTracklets_viper.m for ViPeR Dataset).

ii) Run scripts/extractColorFeatures.m to extract color features for the generated tracklets ( extractColorFeatures_viper.m for ViPeR dataset).

iii) Run scripts/modelColorDriftPatterns.m to learn the color drift model based on the ground truth (modelColorDriftPattern_viper.m for ViPeR dataset).

iv) Run scripts/modelSpatialTemporalTopology1.m for learning spatial-temporal topology model for the university bike path dataset.


Dataset
------------
i) Download the sample dataset archive in a supported format from:https://www.dropbox.com/s/dp558f6rzcd3yke/data.zip?dl=0 and save it in the root folder

ii) Untar the data folder:
tar -xzf data.tar.gz

iii) The folder structure would like this:

~~~
.
├── README.md
├── data
├── data.tar.gz
├── libs
├── scripts
└── src
~~~

### Contact ###
[1] Santhoshkumar Sunderrajan( santhosh@ece.ucsb.edu)

Website: http://santhoshsunderrajan.com/

### Bibtex ###
If you use the code in any of your research works, please cite the following papers:
~~~
@ARTICLE{sunderrajan2015context, 
  author={Sunderrajan, S. and Manjunath, B.S.}, 
  journal={Multimedia, IEEE Transactions on}, 
  title={Context-Aware Hypergraph Modeling for Re-identification and Summarization}, 
  year={2016}, 
  volume={18}, 
  number={1}, 
  pages={51-63}, 
  keywords={Cameras;Clothing;Histograms;Image color analysis;Indexes;Topology;Training;Camera network;person re-identification;search;summarization}, 
  doi={10.1109/TMM.2015.2496139}, 
  ISSN={1520-9210}, 
  month={Jan}
}

@inproceedings{sunderrajan2013context,
  title={Context-aware graph modeling for object search and retrieval in a wide area camera network},
  author={Sunderrajan, Santhoshkumar and Xu, Jiejun and Manjunath, BS},
  booktitle={Distributed Smart Cameras (ICDSC), 2013 Seventh International Conference on},
  pages={1--7},
  year={2013},
  organization={IEEE}
}
~~~

### Disclaimer ###
I may have used some good codes from various sources, please feel free to notify me if you find a piece of code that I need to acknowledge.
