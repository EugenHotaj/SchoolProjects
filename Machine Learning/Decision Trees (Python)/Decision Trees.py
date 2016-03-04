import numpy as np;
import re;
import math;
import matplotlib.pyplot as plt;
import matplotlib.patches as mpatches;
from sklearn.tree import DecisionTreeClassifier;
from sklearn import tree;

feature_file = open("features.txt");
train_file = open("adult_train.txt");
test_file = open("adult_test.txt");

feature_num = 12;
train_num = 32561;
test_num = 16281;

# parse feature maps
feat_dict = {};
index_map = {};

new_index_map={};
rev_index_map={};

num = 0;
for i in range(feature_num):
    curr_line = re.split(": |, ",re.sub(".\n|\.","",feature_file.readline()));
    
    index_map[i] = curr_line[0];
    
    curr_dict = {};
    if(curr_line[1]!="continuous"):
        curr_dict["continuous"] = False;
        for j in range(1,len(curr_line)):
            new_index_map[num] = curr_line[0] + "-" + curr_line[j];
            rev_index_map[curr_line[0] + "-" + curr_line[j]] = num;
            num += 1;
            
            curr_dict[curr_line[j]] = 0;
    else:
        new_index_map[num] = curr_line[0];
        rev_index_map[curr_line[0]] = num;
        num += 1;
        
        curr_dict["continuous"] = True;
        curr_dict["total_val"] = 0;
        curr_dict["total_num"] = 0;
    feat_dict[curr_line[0]] = curr_dict;

# parse train data
feature_set_x = np.array([]).reshape(0,len(new_index_map));
feature_set_y = np.array([]);
empty_features = np.array([]).reshape(0,2);
for i in range(train_num):
    curr_line = re.split(", |,",re.sub("\n","",train_file.readline()));
    curr_feat = np.zeros(len(new_index_map));
    for j in range (len(curr_line)-1):
        if(curr_line[j]=="?"):
            empty_features = np.vstack((empty_features,[i,index_map[j]]));
        else:
            if(not feat_dict[index_map[j]]["continuous"]):
                curr_feat[rev_index_map[index_map[j] + "-" + curr_line[j]]] = 1;
                feat_dict[index_map[j]][curr_line[j]] += 1;
            else:
                curr_feat[rev_index_map[index_map[j]]] = int(curr_line[j]);
                feat_dict[index_map[j]]["total_val"] += int(curr_line[j]);
                feat_dict[index_map[j]]["total_num"] += 1;
    y = 0 if curr_line[12]=="<=50K" else 1;
    feature_set_x = np.vstack((feature_set_x,curr_feat));
    feature_set_y = np.append(feature_set_y,y);

# find mean and mode
feat_avg_dict = {};
for i in range(feature_num):
    if(not feat_dict[index_map[i]]["continuous"]):
        mode = max(feat_dict[index_map[i]],key=feat_dict[index_map[i]].get);
        feat_avg_dict[index_map[i]] = mode;
    else:
        mean = feat_dict[index_map[i]]["total_val"]/feat_dict[index_map[i]]["total_num"];
        feat_avg_dict[index_map[i]] = mean;

# backfill train data
for i in range(len(empty_features)):
    index = empty_features[i];
    if(feat_dict[index[1]]["continuous"]):
        feature_set_x[int(index[0])][rev_index_map[index[1]]] = feat_avg_dict[index[1]];
    else:
        mode_index = feat_avg_dict[index[1]];
        feature_set_x[int(index[0])][rev_index_map[index[1] + "-" + mode_index]] = 1;

# parse test data & backfill
test_x = np.array([]).reshape(0,len(new_index_map));
test_y = np.array([]);
for i in range(test_num):
    curr_line = re.split(", |,",re.sub("\n |.\n","",test_file.readline()));
    curr_feat = np.zeros(len(new_index_map));
    for j in range(len(curr_line)-1):
        if(curr_line[j]=="?"):
            if(not feat_dict[index_map[j]]["continuous"]):
                mode_index = feat_avg_dict[index_map[j]];
                curr_feat[rev_index_map[index_map[j] + "-" + mode_index]] = 1;
            else:
                curr_feat[rev_index_map[index_map[j]]] = feat_avg_dict[index_map[j]];
        else:
            if(not feat_dict[index_map[j]]["continuous"]):
                curr_feat[rev_index_map[index_map[j] + "-" + curr_line[j]]] = 1;
            else:
                curr_feat[rev_index_map[index_map[j]]] = int(curr_line[j]);
    y = 0 if curr_line[12]=="<=50K" else 1;
    test_x = np.vstack((test_x,curr_feat));
    test_y = np.append(test_y,y);

# split train/validate data
r_state = np.random.get_state();
np.random.shuffle(feature_set_x);
np.random.set_state(r_state);
np.random.shuffle(feature_set_y)

split = math.floor(train_num*0.3);

train_x = feature_set_x[split:];
train_y = feature_set_y[split:];

validate_x = feature_set_x[:split];
validate_y = feature_set_y[:split];

# max_depth
d_xaxis = np.array([]);
d_train_acc = np.array([]);
d_validate_acc = np.array([]);
for i in range(1,31):
    d_xaxis = np.append(d_xaxis, i);
    
    clf = DecisionTreeClassifier(max_depth=i);
    clf.fit(train_x,y=train_y);
    
    y = clf.predict(train_x);
    train_acc = np.sum(np.equal(y,train_y))/len(train_y);
    d_train_acc = np.append(d_train_acc,train_acc);
    
    y = clf.predict(validate_x);
    validate_acc = np.sum(np.equal(y,validate_y))/len(validate_y)
    d_validate_acc= np.append(d_validate_acc,validate_acc);

green_patch = mpatches.Patch(color='green', label='Validation Accuracy');
blue_patch = mpatches.Patch(color='blue', label='Training Accuracy')

plt.figure();
plt.title("Max Tree Depth vs. Classificaiton Accuracy");
plt.xlabel("Max Depth");
plt.ylabel("Classification Accuracy");
plt.legend(handles=[green_patch, blue_patch])
plt.plot(d_xaxis, d_train_acc);
plt.plot(d_xaxis, d_validate_acc);
plt.show();

# min samples leaf
l_xaxis = np.array([]);
l_train_acc = np.array([]);
l_validate_acc = np.array([]);
for i in range(1,51):
    l_xaxis = np.append(l_xaxis, i);
    
    clf = DecisionTreeClassifier(min_samples_leaf=i);
    clf.fit(train_x,y=train_y);
    
    y = clf.predict(train_x);
    train_acc = np.sum(np.equal(y,train_y))/len(train_y);
    l_train_acc = np.append(l_train_acc,train_acc);
    
    y = clf.predict(validate_x);
    validate_acc = np.sum(np.equal(y,validate_y))/len(validate_y)
    l_validate_acc = np.append(l_validate_acc,validate_acc);

green_patch = mpatches.Patch(color='green', label='Validation Accuracy');
blue_patch = mpatches.Patch(color='blue', label='Training Accuracy')

plt.figure();
plt.title("Min Samples Required to be a Leaf vs. Clasification Accuracy");
plt.xlabel("Min Samples");
plt.ylabel("Classification Accuracy");
plt.legend(handles=[green_patch, blue_patch])
plt.plot(l_xaxis, l_train_acc);
plt.plot(l_xaxis, l_validate_acc);
plt.show();

# max depth = 12 -- 0.858005733006
# min leaf  = 21 -- 0.855855855856
# optimal classifer = 0.857493857494

# optimal classifier
clf = DecisionTreeClassifier(max_depth = 12, min_samples_leaf=21);
clf.fit(train_x,y=train_y);
y = clf.predict(validate_x);
acc = np.sum(np.equal(y,validate_y))/len(validate_y);
print(acc);

# tree graph
tree.export_graphviz(clf, out_file="tree.dot", feature_names = list(rev_index_map.keys()), max_depth=3,
                     class_names=list(["<=50",">51"]), filled=True, rounded=True,  special_characters=False);  

# test classifer
clf.fit(feature_set_x, y=feature_set_y);
y = clf.predict(test_x);
acc = np.sum(np.equal(y,test_y))/len(test_y);
print(acc);

