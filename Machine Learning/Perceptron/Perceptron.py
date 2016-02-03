import numpy as np;
import matplotlib.pyplot as plt;

train_file = open("spam_train.txt");
test_file = open("spam_test.txt");

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

test_set = test_file.readlines();

    
### Build Dictionary ###
dictionary = {};
default_class = 1;

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

### Perceptron Functions ###
def perceptron_train(data, max_it):
    if(max_it == 0):
        max_it = 1000000;

    w = [0] * len(dictionary);
    k = 0;
    it = 0;

    while(True):
        flag = False;

        for i in range(0,len(data)):
            current_vector = data[i]['v'];
            current_spam = 1 if data[i]['spam'] == 1 else -1;
            
            dot = np.dot(current_vector, w);
            if(dot == 0): 
                dot = default_class; 
            else: 
                dot = 1 if dot > 0 else -1;
                
            if(dot != current_spam):               
                k += 1;

                flag = True;
                w = np.add(w,np.multiply(current_spam,current_vector));       
        
        it += 1;

        if(not flag or it == max_it):
            break;

    return(w,k,it);

def perceptron_test(w,data):
    k = 0;
    
    for i in range (0,len(data)):
        current_vector = data[i]['v'];
        current_spam = 1 if data[i]['spam'] == 1 else -1;
        
        dot = np.dot(current_vector,w);
        if(dot == 0):
            dot = default_class;
        else:
            dot = 1 if dot > 0 else -1;
            
        if(dot != current_spam):
            k+=1;
     
    
    return (k/len(data));

#### Quetion 4 ###
#wv = perceptron_train(train_vectors,0);
#print("Mistakes: " + str(wv[1]));
#print("Error on train_set: " + str(perceptron_test(wv[0],train_vectors)));
#print("Error on validate_set: " + str(perceptron_test(wv[0],validate_vectors)));
#
#### Question 5 ###
#sort_ind = np.argsort(wv[0]);
#print("Most negatively weighted words:");
#for i in sort_ind[0:15]:
#    print(inv_dict[i]);
#    
#print("Most positivley weighted words:");
#for i in sort_ind[-15:]:
#    print(inv_dict[i]);

### Averaged Perceptron ###
def perceptron_train_avereged(data, max_it):
    if(max_it == 0):
        max_it = 1000000;
    
    w = [0] * len(dictionary);
    w_total = [0] * len(dictionary);  
    
    k = 0;
    it = 0;

    while(True):
        flag = False;

        for i in range(0,len(data)):
            current_vector = data[i]['v'];
            current_spam = 1 if data[i]['spam'] == 1 else -1;
            
            dot = np.dot(current_vector, w);
            if(dot == 0): 
                dot = default_class; 
            else: 
                dot = 1 if dot > 0 else -1;
                
            if(dot != current_spam):               
                k += 1;
                flag = True;
                w = np.add(w,np.multiply(current_spam,current_vector));
                
            w_total = np.add(w_total,w);             
        
        it += 1;

        if(not flag or it == max_it):
            break;    
    
    return(np.divide(w_total,it*len(data)),k,it);

#### Question 7 & 8 ###
def train_on_set(data,N):
    p_n = perceptron_train(data[0:N],0);    
    p_a = perceptron_train_avereged(data[0:N],0);
    
    e_n = perceptron_test(p_n[0],validate_vectors);
    e_a = perceptron_test(p_a[0],validate_vectors);
    
    return ((e_n,p_n[2]),(e_a,p_a[2]));
#
#plt_err_n = [];
#plt_err_a = [];
#
#plt_it = [];
#
#data = train_on_set(train_vectors,100);
#plt_err_n.append([100,data[0][0]]);
#plt_err_a.append([100,data[1][0]]);
#plt_it.append([100,data[0][1]]);
#
#data = train_on_set(train_vectors,200);
#plt_err_n.append([200,data[0][0]]);
#plt_err_a.append([200,data[1][0]]);
#plt_it.append([200,data[0][1]]);
#
#data = train_on_set(train_vectors,400);
#plt_err_n.append([400,data[0][0]]);
#plt_err_a.append([400,data[1][0]]);
#plt_it.append([400,data[0][1]]);
#
#data = train_on_set(train_vectors,800);
#plt_err_n.append([800,data[0][0]]);
#plt_err_a.append([800,data[1][0]]);
#plt_it.append([800,data[0][1]]);
#
#data = train_on_set(train_vectors,2000);
#plt_err_n.append([2000,data[0][0]]);
#plt_err_a.append([2000,data[1][0]]);
#plt_it.append([2000,data[0][1]]);
#
#data = train_on_set(train_vectors,4000);
#plt_err_n.append([4000,data[0][0]]);
#plt_err_a.append([4000,data[1][0]]);
#plt_it.append([4000,data[0][1]]);
#
#plt.figure(1);
#plt.xlabel("Size of Training Set");
#plt.ylabel("Error Rate");
#plt.title("Normal Perceptron");
#plt.scatter(np.array(plt_err_n)[:,0],np.array(plt_err_n)[:,1]);
#
#plt.figure(2);
#plt.xlabel("Size of Training Set");
#plt.ylabel("Error Rate");
#plt.title("Avereged Perceptron");
#plt.scatter(np.array(plt_err_a)[:,0],np.array(plt_err_a)[:,1]);
#
#plt.figure(3);
#plt.xlabel("Size of Training Set");
#plt.ylabel("Epochs");
#plt.title("Both Perceptron");
#plt.scatter(np.array(plt_it)[:,0],np.array(plt_it)[:,1]);

### Question 10 ###
#res = perceptron_train_avereged(train_vectors,0);
#it = res[2];
#print(perceptron_test(res[0],validate_vectors));

#for i in range(0,it):
#    wv = perceptron_train(train_vectors,it-i)[0];
#    print(perceptron_test(wv,validate_vectors));
#
#for i in range(0,it+1):
#    wv = perceptron_train_avereged(train_vectors,it-i)[0];
#    print(perceptron_test(wv,validate_vectors));

print(perceptron_test(perceptron_train_avereged(combined_vectors,0)[0],test_vectors));