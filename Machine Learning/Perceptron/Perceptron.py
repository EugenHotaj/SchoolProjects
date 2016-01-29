train_file = open("spam_train.txt");

### Split up training data ###
train_set = [];
validate_set = [];

for i in range (0,5000):
    if(i < 4000) :
        train_set.append(train_file.readline());
    else:
        validate_set.append(train_file.readline());

### Build Dictionary ###
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

dictionary = {key:value for key, value in dictionary.items()
              if value >= 30};

vector_location = 0;
for key in dictionary:
    dictionary[key] = vector_location;
    vector_location += 1;

### Transform data into vectors ###
train_vectors = [];
validate_vectors = [];

def transform_to_vector(string):
    v = [0] * len(dictionary);
    current_string = string.split();
    for i in range(0,len(current_string)):
        word = current_string[i];
        if(word in dictionary):
            v[dictionary[word]] = 1;
    return v;

for i in range(0,len(train_set)):
    train_vectors.append(transform_to_vector(train_set[i]));

for i in range(0, len(validate_set)):
    validate_vectors.append(transform_to_vector(validate_set[i]));


input();
