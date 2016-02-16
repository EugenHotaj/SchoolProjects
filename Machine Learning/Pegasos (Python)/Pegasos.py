## COLLABORATED WITH : Will Bang ##

import numpy as np;
import matplotlib.pyplot as plt;

train_file = open("spam_train.txt");
test_file = open("spam_test.txt");

### Question 1 ###
#pos = np.array([[2,2],[4,4],[4,0]]);
#neg = np.array([[0,0],[2,0],[0,2]]);
#
#plt.figure();
#plt.scatter(pos[:,0],pos[:,1],color=(0,1,0));
#plt.scatter(neg[:,0],neg[:,1],color=(1,0,0));
#plt.plot([0,3],[3,0]);

### Read data, split up training data ###
train_set = [];
validate_set = [];
combined_set = [];
test_set = [];

for i in range (0,5000):
    current_line = train_file.readline();
    combined_set.append(current_line);    
    
    if(i < 4000) :
        train_set.append(current_line);
    else:
        validate_set.append(current_line);

dictionary = {};

for i in range (0,len(train_set)):
    current_string = train_set[i].split();
    current_word_set = {};
        
    for j in range (1,len(current_string)):
        word = current_string[j];
        if(word not in current_word_set):
            if(word in dictionary):
                dictionary[word] += 1;
            else:
                dictionary[word] = 1;
            current_word_set[word] = True;
test_set = test_file.readlines();

    
### Build Dictionary ###

dictionary = {key:value for key, value in dictionary.items()
              if value >= 30};

inv_dict = {};
vector_location = 0;
for key in dictionary:
    dictionary[key] = vector_location;
    inv_dict[vector_location] = key;    
    vector_location += 1;

### Transform data into vectors ###
train_vectors = [];
validate_vectors = [];
combined_vectors = [];
test_vectors = [];

def transform_to_vector(string):
    v = [0] * len(dictionary);
    current_string = string.split();
    spam = int(current_string[0]);
    for i in range(1,len(current_string)):
        word = current_string[i];
        if(word in dictionary):
            v[dictionary[word]] = 1;
    return ({'spam' : spam,'v' : v});

for i in range(0,len(train_set)):
    train_vectors.append(transform_to_vector(train_set[i]));

for i in range(0, len(validate_set)):
    validate_vectors.append(transform_to_vector(validate_set[i]));

combined_vectors.extend(train_vectors);
combined_vectors.extend(validate_vectors);

for i in range(0, len(test_set)):
    test_vectors.append(transform_to_vector(test_set[i]));
    
### Pegasos Functions ###
def pegasos_svm_train(data, lam):
    w = np.zeros(len(dictionary));
    t = 0;
    train_err = 0;
    fw=np.array([]); 

    for i in range(20):
        for j in range(len(data)):
            current_vector = np.array(data[j]['v']);
            current_spam = 1 if data[j]['spam'] == 1 else -1;            
            
            t += 1;       
            nu = 1/(t*lam);
            
            if(np.dot(current_vector,w)*current_spam<1):
                w = (1-nu*lam)*w + nu*current_spam*current_vector;
                train_err+=1;
            else:
                w = (1-nu*lam)*w;  
                
### Question 3 ###
#        curr_sum = 0;
#        for j in range(len(data)):
#            current_vector = np.array(data[j]['v']);
#            current_spam = current_spam = 1 if data[j]['spam'] == 1 else -1; 
#            
#            curr_sum += np.maximum(0,1-current_spam*np.dot(w,current_vector));
#        
#        fw = np.append(fw,(lam/2)*np.dot(w,w)+curr_sum/len(data));
    return (w,fw,train_err/(20*len(data)));
#
#ans = pegasos_svm_train(train_vectors, 2**-5);
#plt.scatter(range(len(train_vectors),21*len(train_vectors),len(train_vectors)),ans[1])

def pegasos_svm_test(data,w):
    k = 0;
    
    for i in range (0,len(data)):
        current_vector = np.array(data[i]['v']);
        current_spam = 1 if data[i]['spam'] == 1 else -1;
            
        if(current_spam*np.dot(current_vector,w) < 0):
            k+=1;
    
    return (k/len(data));

### Question 3 ###
#x_axis = [];
#train_errors = [];
#hinge_errors = [];
#validate_errors = [];
#
#for i in range(11):
#    x_axis.append(i-10+1);    
#    ans = pegasos_svm_train(train_vectors,2**(i-10+1));
#    train_errors.append(ans[2]);
#    
#    curr_sum = 0;
#    for j in range(len(train_vectors)):
#        current_vector = np.array(train_vectors[j]['v']);
#        current_spam = 1 if train_vectors[j]['spam'] == 1 else -1;
#        
#        curr_sum += np.maximum(0,1-current_spam*np.dot(ans[0],current_vector));
#    curr_sum /= len(train_vectors);
#    
#    hinge_errors.append(curr_sum);
#    
#    ans = pegasos_svm_test(validate_vectors,ans[0]);
#    validate_errors.append(ans);
#    print(i);
#
#plt.figure();
#plt.plot(x_axis,train_errors,color=(1,0,0));
#plt.plot(x_axis,hinge_errors,color=(0,1,0));
#plt.plot(x_axis,validate_errors,color=(0,0,1));
#plt.title("Pegasos Errors");

#ans = pegasos_svm_train(train_vectors,2**-8);
#ans = pegasos_svm_test(test_vectors,ans[0]);
#sv = 0;
#av = 0;
#for j in range(len(train_vectors)):
#    current_vector = np.array(train_vectors[j]['v']);
#    current_spam = 1 if train_vectors[j]['spam'] == 1 else -1;
#
#    if(abs(np.dot(ans[0],current_vector))<=1) :
#        av+=1;
#    
#    if(current_spam*np.dot(ans[0],current_vector) <= 1):
#        sv += 1;

#ans = pegasos_svm_test(test_vectors,ans[0]);