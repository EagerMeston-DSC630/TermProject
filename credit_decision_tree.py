import numpy as np
import pandas as pd
from pandas.api.types import is_numeric_dtype


class TreeNode:
    def __init_subclass__(cls):
        if "predict" not in cls.__dict__ or not callable(cls.predict):
            raise NotImplementedError(
                "All Nodes must implement an predict method"
            )


class RootNode(TreeNode):
    def __init__(self):
        pass

    def add_child(self, child_node, side):
        if not issubclass(type(child_node), TreeNode):
            raise TypeError(
                "Only TreeNode objects may be added as children in the tree."
            )
        self.child = child_node

    def predict(self, observation):
        return self.child.predict(observation)


class DecisionNode(TreeNode):
    def __init__(self, attr_name, attr_val, attr_kind):
        # print(attr_name, attr_val)
        self.attr_name = attr_name
        if attr_kind == "numeric":
            self.condition = lambda x: x <= attr_val
        else:
            self.condition = lambda x: x == attr_val

    def add_child(self, child_node, side):
        if not issubclass(type(child_node), TreeNode):
            raise TypeError(
                "Only TreeNode objects may be added as children in the tree."
            )
        if side == "yes":
            self.yes_child = child_node
        elif side == "no":
            self.no_child = child_node
        else:
            raise ValueError("side may only be equal to 'yes' or 'no'")

    def predict(self, observation):
        if self.condition(observation[self.attr_name]):
            return self.yes_child.predict(observation)
        else:
            return self.no_child.predict(observation)


class LeafNode(TreeNode):
    def __init__(self, prediction, purity, size):
        print("=", prediction, size, purity)
        self.prediction = prediction
        self.purity = purity
        self.size = size

    def predict(self, observation):
        return self.prediction


class DecisionTree:
    def __init__(self, min_leafsize, min_leafpurity, split_metric="cart"):
        self.min_leafsize = min_leafsize
        self.min_leafpurity = min_leafpurity
        self.split_metric = split_metric

    def fit(self, predictors, target, data):
        self.data = data
        self.predictors = predictors
        self.target = target
        self.priors = data[self.target].value_counts() / data.shape[0]
        self.leaf_nodes_ = list()
        self.leaf_node_num = 0
        self.root_node = RootNode()
        if self.split_metric == "cart":
            self._build_cart_tree(self.data, self.root_node, side="yes")
        elif self.split_metric == "entropy":
            self._build_entropy_tree(self.data, self.root_node, side="yes")
        return self

    def predict(self, unlabeled_data):
        return pd.DataFrame(
            (
                self.root_node.predict(obs)
                for _, obs in unlabeled_data.iterrows()
            ),
            index=unlabeled_data.index,
        )

    def _build_entropy_tree(self, data, parent_node, side):
        partition_size = data.shape[0]
        label_counts = data[self.target].value_counts()
        purity = label_counts.max() / partition_size
        # Should the tree be premptively pruned?
        if partition_size <= self.min_leafsize or purity >= self.min_leafpurity:
            parent_node.add_child(
                LeafNode(self.leaf_node_num, partition_size, purity), side=side
            )
            self.leaf_nodes_.append(data)
            self.leaf_node_num += 1
            return
        # Determine the best split condition for a DecisionNode
        best_split_attribute = None
        best_split_value = None
        best_splitter = None
        split_attribute_kind = None
        best_split_score = 0
        for attr_name, attr_series in data.loc[:, self.predictors].items():
            if is_numeric_dtype(attr_series.dtype):
                (
                    value,
                    score,
                    splitter,
                ) = self._evaluate_numeric_attribute_entropy(data, attr_name)
                if score > best_split_score:
                    best_split_attribute = attr_name
                    best_split_value = value
                    best_splitter = splitter
                    best_split_score = score
                    split_attribute_kind = "numeric"
            else:
                (
                    value,
                    score,
                    splitter,
                ) = self._evaluate_categorical_attribute_entropy(
                    data, attr_name
                )
                if score > best_split_score:
                    best_split_attribute = attr_name
                    best_split_value = value
                    best_splitter = splitter
                    best_split_score = score
                    split_attribute_kind = "category"
        # Add a LeafNode if none of the attributes made useful splits
        if best_split_attribute is None:
            parent_node.add_child(
                LeafNode(self.leaf_node_num, partition_size, purity), side=side
            )
            self.leaf_nodes_.append(data)
            self.leaf_node_num += 1
            return
        # Otherwise add a DecisionNode and keep building the tree
        decision_node = DecisionNode(
            best_split_attribute, best_split_value, split_attribute_kind
        )
        parent_node.add_child(decision_node, side=side)
        data_y = data.loc[best_splitter]
        data_n = data.loc[~best_splitter]
        self._build_entropy_tree(data_y, decision_node, "yes")
        self._build_entropy_tree(data_n, decision_node, "no")

    def _evaluate_numeric_attribute_entropy(self, data, attr_label):
        data.sort_values(by=attr_label, inplace=True)
        midpoints = []
        for j in range(data.shape[0] - 1):
            xj, xj1 = data.iloc[j][attr_label], data.iloc[j + 1][attr_label]
            if xj1 != xj:
                midpoints.append((xj1 + xj) / 2)
        max_varg, max_score, max_splitter = 0, 0, None
        for v in midpoints:
            splitter = data[attr_label] <= v
            v_score = self.compute_information_gain(data, data[attr_label] <= v)
            if v_score > max_score:
                max_score = v_score
                max_varg = v
                max_splitter = splitter
        return max_varg, max_score, max_splitter

    def _evaluate_categorical_attribute_entropy(self, data, attr_label):
        max_varg, max_score, max_splitter = str(), 0, None
        for v in data[attr_label].unique():
            splitter = data[attr_label] == v
            v_score = self.compute_information_gain(data, splitter)
            if v_score > max_score:
                max_score = v_score
                max_varg = v
                max_splitter = splitter
        return max_varg, max_score, max_splitter

    def compute_entropy(self, data):
        label_probs = data[self.target].value_counts() / data.shape[0]
        return -np.sum(label_probs * np.log2(label_probs))

    def compute_split_entropy(self, data_y, data_n, N):
        return (
            data_y.shape[0] * self.compute_entropy(data_y)
            + data_n.shape[0] * self.compute_entropy(data_n)
        ) / N

    def compute_information_gain(self, data, splitter):
        data_y = data.loc[splitter]
        data_n = data.loc[~splitter]
        return self.compute_entropy(data) - self.compute_split_entropy(
            data_y, data_n, data.shape[0]
        )

    def _build_cart_tree(self, data, parent_node, side):
        partition_size = data.shape[0]
        label_counts = data[self.target].value_counts()
        purity = label_counts.max() / partition_size
        # Should the tree be premptively pruned?
        if partition_size <= self.min_leafsize or purity >= self.min_leafpurity:
            parent_node.add_child(
                LeafNode(self.leaf_node_num, partition_size, purity), side=side
            )
            self.leaf_nodes_.append(data)
            self.leaf_node_num += 1
            return
        # Determine the best split condition for a DecisionNode
        best_split_attribute = None
        best_split_value = None
        best_splitter = None
        split_attribute_kind = None
        best_split_score = 0
        for attr_name, attr_series in data.loc[:, self.predictors].items():
            if is_numeric_dtype(attr_series.dtype):
                (
                    value,
                    score,
                    splitter,
                ) = self._evaluate_numeric_attribute_cart(data, attr_name)
                if score > best_split_score:
                    best_split_attribute = attr_name
                    best_split_value = value
                    best_splitter = splitter
                    best_split_score = score
                    split_attribute_kind = "numeric"
            else:
                (
                    value,
                    score,
                    splitter,
                ) = self._evaluate_categorical_attribute_cart(data, attr_name)
                if score > best_split_score:
                    best_split_attribute = attr_name
                    best_split_value = value
                    best_splitter = splitter
                    best_split_score = score
                    split_attribute_kind = "category"
        # Add a LeafNode if none of the attributes improve split
        if best_split_attribute is None:
            parent_node.add_child(
                LeafNode(self.leaf_node_num, partition_size, purity), side=side
            )
            self.leaf_nodes_.append(data)
            self.leaf_node_num += 1
            return
        # Otherwise add a DecisionNode and keep building the tree
        decision_node = DecisionNode(
            best_split_attribute, best_split_value, split_attribute_kind
        )
        parent_node.add_child(decision_node, side=side)
        data_y = data.loc[best_splitter]
        data_n = data.loc[~best_splitter]
        self._build_cart_tree(data_y, decision_node, "yes")
        self._build_cart_tree(data_n, decision_node, "no")

    def _evaluate_numeric_attribute_cart(self, data, attr_label):
        data.sort_values(by=attr_label, inplace=True)
        midpoints = []
        for j in range(data.shape[0] - 1):
            xj, xj1 = data.iloc[j][attr_label], data.iloc[j + 1][attr_label]
            if xj1 != xj:
                midpoints.append((xj1 + xj) / 2)
        max_varg, max_score, max_splitter = 0, -100, None
        for v in midpoints:
            splitter = data[attr_label] <= v
            v_score = self.compute_cart(
                data.loc[splitter], data.loc[~splitter], data.shape[0]
            )
            if v_score > max_score:
                max_score = v_score
                max_varg = v
                max_splitter = splitter
        return max_varg, max_score, max_splitter

    def _evaluate_categorical_attribute_cart(self, data, attr_label):
        max_varg, max_score, max_splitter = str(), -100, None
        for v in data[attr_label].unique():
            splitter = data[attr_label] == v
            v_score = self.compute_cart(
                data.loc[splitter], data.loc[~splitter], data.shape[0]
            )
            if v_score > max_score:
                max_score = v_score
                max_varg = v
                max_splitter = splitter
        return max_varg, max_score, max_splitter

    def compute_cart(self, data_y, data_n, N):
        label_probs_y = data_y[self.target].value_counts() / data_y.shape[0]
        label_probs_n = data_n[self.target].value_counts() / data_n.shape[0]
        return (
            2 * data_y.shape[0] * data_n.shape[0] / (N * N)
        ) * label_probs_y.subtract(label_probs_n).abs().sum()
