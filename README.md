# The Contents of this Project

## Directories
The main directories that contain data read into the scripts and notebooks for this project are:
- **/data** – contains the datasets for use in this project.  Some could only be uploaded to GitHub as zip files because of their size, so those ones will need to be manually extracted in the data directory before the scripts and Jupyter Notebooks that use them will run properly.
- **/model_evaluation** – contains key pandas.DataFrame objects and lists of predictions related to the model building and testing phases.  The two zip files (***cred_tree.zip*** and ***cred_tree_no_zeros.zip***) are compressed .pkl files of the fully trained predictive clustering trees from ***predictive_clustering_tree.ipynb*** and ***zeroless_predictive_clustering_tree.ipynb***.  They can be loaded into a Python session using the **dill** library.  This can save a lot of time, as the first tree took over 4.5 hours to train.
- *The remaining directories are outputs produced by Jupyter Notebooks as described below.*

## Scripts and Notebooks
The main scripts and notebooks for this project are almost all numbered:
- **00 EDA.R** – An R script where the initial data analysis occurred of the two original datasets, which are ***/data/application_record.csv*** and ***/data/credit_record.csv***.
- **01 score_brainstorming.R** – An R script brainstorming different methods for computing the reliability score based on payment status history.
- **02 train_test_set.R** – Encodes the payment STATUS variable as an integer vector rather than a character vector, calculates two different versions of the reliability score, produces a new version of the dataset containing these scores and writes it to /data/train_test_set.csv
- **03 train_test_set2.R** – Computes 10 versions of the reliability score, produces a new version of the dataset containing them, and writes it to /data/train_test_set2.csv
- **04 numeric_score_regression.ipynb** - 
- **05 predictive_clustering_tree.ipynb** - 
- **06 zeroless_predictive_predictive_clustering_tree.ipynb** - 
- **07 leaf_node_EDA.ipynb** - 
- **08 sklearn_DecisionTreeRegressor.ipynb** - 
- **09 predictive_clustering_example_use.ipynb** – 
- **credit_decision_tree.py** – Contains definitions pertaining to the custom decision tree class used for predictive clustering in the predictive_clustering_tree.ipynb and zeroless_predictive_clustering_tree.ipynb Jupyter Notebooks.
