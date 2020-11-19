# The Contents of this Project

## Directories
- **/data** – contains the datasets for use in this project.  Some could only be uploaded to GitHub as zip files because of their size, so those ones will need to be manually extracted in the data directory before the scripts and Jupyter Notebooks that use them will run properly.
- **/model_evaluation** – contains key pandas.DataFrame objects and lists of predictions related to the model building and testing phases.  The two zip files (***cred_tree.zip*** and ***cred_tree_no_zeros.zip***) are compressed .pkl files of the fully trained predictive clustering trees from ***predictive_clustering_tree.ipynb*** and ***zeroless_predictive_clustering_tree.ipynb***.  They can be loaded into a Python session using the **dill** library.  This can save a lot of time, as the first tree took over 4.5 hours to train.
- *The remaining directories are outputs produced by Jupyter Notebooks described below.*

## Scripts and Notebooks
- **00 EDA.R** – An R script where the initial data analysis occurred of the two original datasets, which are ***/data/application_record.csv*** and ***/data/credit_record.csv***.
- **01 score_brainstorming.R** – An R script brainstorming different methods for computing the reliability score based on payment status history.
- **02 train_test_set.R** – Encodes the payment STATUS variable as an integer vector rather than a character vector, calculates two different versions of the reliability score, produces a new version of the dataset containing these scores and writes it to ***/data/train_test_set.csv***.
- **03 train_test_set2.R** – Computes 10 versions of the reliability score, produces a new version of the dataset containing them, and writes it to ***/data/train_test_set2.csv***.
- **04 numeric_score_regression.ipynb** - Splits records from ***train_test_set2.csv*** into a training set and a testing set. Then fits and evaluates linear regression and decision tree regression models to the 10 versions of the numeric score using the statsmodels formula api and the DecisionTreeRegressork from sklearn.
- **05 predictive_clustering_tree.ipynb** - Splits records from ***data/cred_record_train_test.csv*** into a training and testing set.  Then uses a DecisionTree (a custom class defined in ***credit_decision_tree.py***) to cluster records into leaf nodes.  This fully trained model has been saved as ***cred_tree.pkl*** and archived as ***/model_evalution/cred_tree.zip*** and can be reloaded into a Python session using the dill library to avoid retraining it.  PMFs of the payment status variable are computed for each leaf node and used as cluster prototypes.  The payment status PMF of each record in the test set is predicted to be the cluster prototype PMF of the leaf node that the DecisionTree places it in.  The accuracy of the model predictions is evaluated.
- **06 zeroless_predictive_predictive_clustering_tree.ipynb** - Drops all records from ***data/cred_record_train_test.csv*** that have a payment status of 0, and then splits them into a training and testing set.  Uses a DecisionTree (a custom class defined in ***credit_decision_tree.py***) to cluster those records into leaf nodes.  This fully trained model has been saved as ***cred_tree.pkl*** and archived as ***/model_evalution/cred_tree_no_zeros.zip*** and can be reloaded into a Python session using the dill library to avoid retraining it.  PMFs of the payment status variable are computed for each leaf node and used as cluster prototypes.  The payment status PMF of each record in the test set is predicted to be the cluster prototype PMF of the leaf node that the DecisionTree places it in.  The accuracy of the model predictions is evaluated.
- **07 leaf_node_EDA.ipynb** - 
- **08 sklearn_DecisionTreeRegressor.ipynb** - 
- **09 predictive_clustering_example_use.ipynb** – 
- **credit_decision_tree.py** – Contains definitions pertaining to the custom decision tree class used for predictive clustering in the ***predictive_clustering_tree.ipynb*** and ***zeroless_predictive_clustering_tree.ipynb*** Jupyter Notebooks.

## Other Documents
- **EagerMeston_FinalPaper.docx** - A Word Document containing an executive summary and technical overview of the project results.  Discusses the predictive clustering trees in detail.
- **EagerMeston_FinalPaper.pdf** - A PDF version of ***EagerMeston_FinalPaper.docx***.
- **EagerMeston_FinalPresentation.pptx** - A PowerPoint presentation with audio narration that explains the process we went through for this project and the results of our analysis.  It takes 18 minutes and 53 seconds to view.
