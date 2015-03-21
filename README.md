A multi-camera object search and retrieval algorithm using matlab.

This is a matlab implementation of the papers "Context-Aware Hypergraph Modeling for Re-identification and Summarization" submitted to TMM and "Context-Aware Graph Modeling for Object Search and Retrieval in a Wide Area Camera Network" published in ICDSC'13.

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
i) Download the sample dataset archive in a supported format from: and save it in the root folder

ii) Untar the data folder:
tar -xzf data.tar.gz

iii) The folder structure would like this:

~~~
.
├── README.md
├── data
├── data.tar.gz
├── libs
└── src
~~~

### Contact ###
[1] Santhoshkumar Sunderrajan( santhosh@ece.ucsb.edu)

Website: http://vision.ece.ucsb.edu/~santhosh/

### Bibtex ###
If you use the code in any of your research works, please cite the following papers:
~~~
@inproceedings{sunderrajan2013context,
  title={Context-Aware Hypergraph Modeling for Re-identification and Summarization},
  author={Sunderrajan, Santhoshkumar and Manjunath, BS},
  year={2015}
}

@inproceedings{sunderrajan2013context,
  title={Context-Aware Graph Modeling for Object Search and Retrieval in a Wide Area Camera Network},
  author={Sunderrajan, Santhoshkumar and Xu, Jiejun and Manjunath, BS},
  booktitle={Proc. International Conference on Distributed Smart Cameras},
  year={2013}
}
~~~

### Disclaimer ###
I may have used some good codes from various sources, please feel free to notify me if you find a piece of code that I need to acknowledge.