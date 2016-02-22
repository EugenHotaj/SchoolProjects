import numpy as np;
import matplotlib.pyplot as plt;
from sklearn import cross_validation as cv;
from sklearn.cross_validation import cross_val_score as cvs;
from sklearn.svm import SVC;
from sklearn.multiclass import OneVsRestClassifier;

### Read in data and create feature vectors ###
train_file = open("mnist_train.txt");
test_file = open("mnist_train.txt");

train_num = 2000;
test_num = 1000;

image_size = 28*28;

train_set = np.array([]);
train_set_y = np.array([]);
train_set_x = np.array([]).reshape(0,image_size);

test_set = np.array([]);
test_set_y = np.array([]);
test_set_x = np.array([]).reshape(0,image_size);

for i in range(train_num):
    curr = np.array(train_file.readline().split(","));
    curr = curr.astype(np.int);
    
    n = curr[0];
    v = 2*curr[1:]/255-1;
    train_set = np.append(train_set, {"n" : n, "v" : v});
    train_set_y = np.append(train_set_y,n);
    train_set_x = np.vstack((train_set_x,v));    
    
for i in range(test_num):
    curr = np.array(test_file.readline().split(","));
    curr = curr.astype(np.int);
    
    n = curr[0];
    v = 2*curr[1:]/255-1;

    test_set = np.append(test_set, {"n" : n, "v" : v});
    test_set_y = np.append(test_set_y,n);
    test_set_x = np.vstack((test_set_x,v));  

### Pegasos Functions ###
def pegasos_svm_train(data, lam):
    w = np.array([]).reshape(0,image_size);    
    
    for k in range(10):
        w_k = np.zeros(image_size);
        t = 0;

        for i in range(20):
            for j in range(len(data)):
                x = data[j]['v'];
                y = 1 if data[j]['n'] == k else -1;            
                
                t += 1;       
                nu = 1/(t*lam);
                
                if(np.dot(x,w_k)*y<1):
                    w_k = (1-nu*lam)*w_k + nu*y*x;
                else:
                    w_k = (1-nu*lam)*w_k;  
        w = np.vstack((w,w_k));            
    return (w);
    
def pegasos_svm_test(data, w):
    k = 0;
    
    for i in range (0,len(data)):
        x = data[i]['v'];
        y = data[i]['n'];
        
        num = -1;
        score = -1000000;
        
        for i in range(10):  
            curr_score = np.dot(x,w[i]);
            if(curr_score > score):
                score = curr_score;
                num = i;
        
        if y!=num:
            k +=1;
            
    return (k/len(data));

### Question 2c ###
x_axis = [];
y_axis = [];
for i in range(7):
    lam = 2**(i-7+2)
    x_axis.append(lam);
    kf = cv.KFold(len(train_set),5);
    
    x=0;
    for train , test in kf:
        w = pegasos_svm_train(train_set[train], lam);
        x+= pegasos_svm_test(train_set[test], w);
    
    y_axis.append(x/5);
    print(i);

plt.title("Cross Validation Error");
plt.xlabel("Lambda");
plt.ylabel("Error");
plt.plot(x_axis,y_axis);

w = pegasos_svm_train(train_set,2**-3);
print(pegasos_svm_test(test_set,w));

### Question 2d###
clf = OneVsRestClassifier(SVC()).fit(train_set_x, train_set_y);
y = clf.predict(test_set_x);
print((test_num-np.sum(np.equal(y,test_set_y)))/test_num);

### Question 2e ###
print(1-np.mean(cvs(SVC(),train_set_x,y=train_set_y,cv=10)));

### Question 2f ###