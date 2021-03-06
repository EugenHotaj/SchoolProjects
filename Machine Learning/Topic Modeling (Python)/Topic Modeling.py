from gensim import corpora, models, similarities

# build corpus
corpus = corpora.ucicorpus.UciCorpus('docword.nips.txt','vocab.nips.txt');

# build lda models

# default (num_topics=100)
lda_default = models.ldamodel.LdaModel(corpus, id2word=corpus.id2word);

# lda_numtopics
lda_2  = models.ldamodel.LdaModel(corpus, id2word=corpus.id2word, num_topics=2);
lda_5  = models.ldamodel.LdaModel(corpus, id2word=corpus.id2word, num_topics=5);
lda_10 = models.ldamodel.LdaModel(corpus, id2word=corpus.id2word, num_topics=10);
lda_20 = models.ldamodel.LdaModel(corpus, id2word=corpus.id2word, num_topics=20);
lda_50 = models.ldamodel.LdaModel(corpus, id2word=corpus.id2word, num_topics=50);

# print

print(lda_default.print_topics(100));
print(lda_2.print_topics(2));
print(lda_5.print_topics(5));
print(lda_10.print_topics(10));
print(lda_20.print_topics(20));
print(lda_50.print_topics(50));

