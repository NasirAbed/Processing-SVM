import psvm.*;

SVM model;

String trainingDocuments[] = {
    "FREE NATIONAL TREASURE",     // Spam
    "FREE TV for EVERY visitor",   // Spam
    "Peter and Stewie are hilarious", // OK
    "AS SEEN ON NATIONAL TV",      // SPAM
    "FREE drugs",          // SPAM
    "New episode rocks, Peter and Stewie are hilarious", // OK
    "Peter is my fav!"        // OK
};

int labels[] = {
  1, 1, 0, 1, 1, 0, 0
};

String testDocuments[] = {
    "FREE lotterry for the NATIONAL TREASURE !!!", // Spam
    "Stewie is hilarious",     // OK
    "Poor Peter ... hilarious",    // OK
    "I love this show",
    "Free gold just click HERE.",
    "Best episode ever"
};

ArrayList<String> globalDictionary;

void buildGlobalDictionary() {
  globalDictionary = new ArrayList<String>();
  for (int i = 0; i < trainingDocuments.length; i++) {
    String doc = trainingDocuments[i];
    String words[] = split(doc, ' ');
    for (int w = 0; w < words.length; w++) {
      String word = words[w].toLowerCase();
      word = word.replaceAll("\\W", "");
      if (!globalDictionary.contains(word)) {
        globalDictionary.add(word);
      }
    }
  }

  for (int i = 0; i < testDocuments.length; i++) {
    String doc = testDocuments[i];
    String words[] = split(doc, ' ');
    for (int w = 0; w < words.length; w++) {
      String word = words[w].toLowerCase();
      word = word.replaceAll("\\W", "");
      if (!globalDictionary.contains(word)) {
        globalDictionary.add(word);
      }
    }
  }

  println(globalDictionary);
}

int[] buildVector(String input) {
  String[] words = split(input, ' ');
  ArrayList<String> normalizedWords = new ArrayList();
  for (int w = 0; w < words.length; w++) {
    words[w] = words[w].replaceAll("\\W", "");
    normalizedWords.add(words[w].toLowerCase());
  }

  int[] result = new int[globalDictionary.size()];
  for (int i = 0; i < globalDictionary.size(); i++) {
    String word = globalDictionary.get(i);
    if (normalizedWords.contains(word)) {
      result[i] = 1;
    } 
    else {
      result[i] = 0;
    }
  }
  return result;
}

void setup() {
  size(500,500);
  buildGlobalDictionary();

  int[][] trainingVectors = new int[trainingDocuments.length][1];
  for(int i = 0; i < trainingDocuments.length; i++){
    trainingVectors[i] = buildVector(trainingDocuments[i]);
  }

  model = new SVM(this);
  SVMProblem problem = new SVMProblem();
  problem.setNumFeatures(1);
  problem.setSampleData(labels, trainingVectors);
  model.train(problem);
  
  int[][] testVectors = new int[testDocuments.length][1];
  for(int i = 0; i < testDocuments.length; i++){
    testVectors[i] = buildVector(testDocuments[i]);
  }
  
  for(int i = 0; i < testDocuments.length; i++){
    println("testing: " + testDocuments[i] );
    double score = model.test(testVectors[i]); 
    println("result: " + score);
  } 
}

void draw() {
background(0);
for (int i =0; i < testDocuments.length; i++) {
    double score = model.test(buildVector(testDocuments[i]));
    if(score == 0){
      fill(0,255,0);
    } else {
      fill(255,0,0);
    }
    text(testDocuments[i] + " [score: "+score+"]", 10, 20*i + 20);
  }
}

void saveGlobalDictionary(){
  String[] strings = new String[globalDictionary.size()];
  strings = globalDictionary.toArray(strings);
  saveStrings(dataPath("dictionary.txt"), strings);
}

void keyPressed(){
  saveGlobalDictionary();
  model.saveModel("model.txt");
}
