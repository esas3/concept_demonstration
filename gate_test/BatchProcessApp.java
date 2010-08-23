/*
 * Gate Document Batch Processor
 *
 * Adapted from http://doiop.com/GateBatchProcessApp.java
 */
import gate.Document;
import gate.Corpus;
import gate.CorpusController;
import gate.AnnotationSet;
import gate.Annotation;
import gate.Gate;
import gate.Factory;
import gate.util.*;
import gate.util.persistence.PersistenceManager;


import org.openrdf.OpenRDFException;
import org.openrdf.model.URI;
import org.openrdf.model.ValueFactory;
import org.openrdf.model.vocabulary.RDF;
import org.openrdf.model.vocabulary.RDFS;
import org.openrdf.repository.Repository;
import org.openrdf.repository.RepositoryConnection;
import org.openrdf.repository.http.HTTPRepository;


import java.util.Set;
import java.util.HashSet;
import java.util.List;
import java.util.ArrayList;
import java.util.Iterator;

import java.io.File;
import java.io.FileOutputStream;
import java.io.BufferedOutputStream;
import java.io.OutputStreamWriter;
import java.io.FileReader;
import java.io.BufferedReader;


/**
 * This class loads a GATE application and runs it against the provided files.
 */
public class BatchProcessApp {
  public static void main(String[] args) throws Exception {
    parseCommandLine(args);

    // initialise GATE - this must be done before calling any GATE APIs
    Gate.init();
    
    Repository myRepository = new HTTPRepository(sesameServer, repositoryID);
    myRepository.initialize();
    
    ValueFactory f = myRepository.getValueFactory();
    

    // load the saved application
    CorpusController application =
      (CorpusController)PersistenceManager.loadObjectFromFile(gappFile);

    Corpus corpus = Factory.newCorpus("BatchProcessApp Corpus");
    application.setCorpus(corpus);

    for(int i = firstFile; i < args.length; i++) {
      File idFile = new File(args[i]);
      File docFile = new File(workingDir + "/" +
                      new BufferedReader(new FileReader(idFile)).readLine());
      System.out.print("Processing document " + docFile + "...");
      Document doc = null;
      try {
        doc = Factory.newDocument(docFile.toURI().toURL(), encoding);
      } catch(Exception e) {
        System.out.println("FAILED.");
        continue;
      }

      // Add the document to the corpus, run the application, and finally
      // remove the document from the corpus to prepare it for the next run.
      corpus.add(doc);
      application.execute();
      corpus.clear();

      String docXMLString = null;

      System.out.println("Annotations: " + doc.getAnnotations("onto").toString());
      
      // Store all generated Annotations in the Sesame RDF store.
      for(Annotation a:doc.getAnnotations("onto")) {
        URI concept = f.createURI(a.getFeatures().get("ontology")+"#"+a.getFeatures().get("class"));
        URI document = f.createURI(docFile.getCanonicalFile().toURI().toURL().toString());
        URI topic = f.createURI("http://xmlns.com/foaf/0.1/primaryTopic");
        
        try {
          RepositoryConnection con = myRepository.getConnection();
          
          try {
            con.add(document, topic, concept);
          } finally {
            con.close();
          }
        } catch (OpenRDFException e) {
             // handle exception
        }
      }

      Factory.deleteResource(doc);

      System.out.println("done");
    }

    System.out.println("All done");
  }


  private static void parseCommandLine(String[] args) throws Exception {
    System.out.println("Processing: " + args.toString());
    int i;
    for(i = 0; i < args.length && args[i].charAt(0) == '-'; i++) {
      switch(args[i].charAt(1)) {
        case 'g':
          gappFile = new File(args[++i]);
          break;
        case 's':
          sesameServer = args[++i];
          System.out.println("Sesame Server: " + sesameServer);
          break;
        case 'r':
          repositoryID = args[++i];
          System.out.println("Repository ID: " + repositoryID);
          break;
        case 'w':
          workingDir = args[++i];
          System.out.println("Working Dir: " + workingDir);
          break;
        default:
          System.out.println("Unrecognized option " + args[i]);
          usage();
      }
    }

    firstFile = i;

    if(gappFile == null) {
      System.err.println("No .gapp file specified");
      usage();
    }
  }

  private static final void usage() {
    System.err.println(
      "Usage:\n" +
      "   java BatchProcessApp -g <gappFile> file1 file2 ... fileN\n" +
      "\n" +
      "-g gappFile\n" +
      "-r repositoryId\n" +
      "-s sesameServer\n" +
      "-w workingDir\n"
   );

    System.exit(1);
  }

  private static int firstFile = 0;
  private static File gappFile = null;
  private static String encoding = null;
  // Sesame configuration
  private static String sesameServer = "http://localhost:8080/openrdf-sesame/";
  private static String repositoryID = "ESA";
  private static String workingDir = "/tmp/esa";
}