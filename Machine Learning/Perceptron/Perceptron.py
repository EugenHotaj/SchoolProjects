import numpy as np;

train_file = open("spam_train.txt");
test_file = open("spam_test.txt");

### Split up training data ###
train_set = [];
validate_set = [];
combined_set = [];

for i in range (0,5000):
    current_line = train_file.readline();
    combined_set.append(current_line);    
    
    if(i < 4000) :
        train_set.append(current_line);
    else:
        validate_set.append(current_line);
    
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

vector_location = 0;
for key in dictionary:
    dictionary[key] = vector_location;
    vector_location += 1;

### Transform data into vectors ###
train_vectors = [];
validate_vectors = [];
combined_vectors = [];

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
        
        if(not flag or it == max_it-1):
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

print(perceptron_test(perceptron_train(train_vectors,0)[0],train_vectors));

### Inspect Parameters ###

### Averaged Perceptron ###
def perceptron_train_avereged(data, max_it):
    if(max_it == 0):
        max_it = 1000000;
    
    return;
    
### Plots ###

