package com.thenetcircle.services.faiss4j.tests;

import com.thenetcircle.services.faiss.IndexFlatL2;
import com.thenetcircle.services.faiss.RangeSearchResult;
import com.thenetcircle.services.faiss.floatArray;
import com.thenetcircle.services.faiss.longArray;
import org.junit.BeforeClass;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.nio.file.Paths;
import java.util.Random;

public class Examples {
    private static final Logger log = LoggerFactory.getLogger(Examples.class);

    @Test
    public void testLogger() {
        log.info("test logger");
    }

    @BeforeClass
    public static void load() {
        System.load(Paths.get("./swigfaiss4j.so").toAbsolutePath().toString());
        System.loadLibrary("faiss");
    }

    public static String toString(longArray a, int rows, int cols) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < rows; i++) {
            sb.append(i).append('\t').append('|');
            for (int j = 0; j < cols; j++) {
                sb.append(String.format("%5d ", a.getitem(i * cols + j)));
            }
            sb.append("\n");
        }
        return sb.toString();
    }

    public static String toString(floatArray a, int rows, int cols) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < rows; i++) {
            sb.append(i).append('\t').append('|');
            for (int j = 0; j < cols; j++) {
                sb.append(String.format("%7g ", a.getitem(i * cols + j)));
            }
            sb.append("\n");
        }
        return sb.toString();
    }

    public static floatArray makeFloatArray(float[][] vectors) {
        int d = vectors[0].length;
        int nb = vectors.length;
        floatArray fa = new floatArray(d * nb);
        for (int i = 0; i < nb; i++) {
            for (int j = 0; j < d; j++) {
                fa.setitem(d * i + j, vectors[i][j]);
            }
        }
        return fa;
    }

    public static longArray makeLongArray(int[] ints) {
        int len = ints.length;
        longArray la = new longArray(len);
        for (int i = 0; i < len; i++) {
            la.setitem(i, ints[i]);
        }
        return la;
    }

    @Test
    public void testFlat() {
        int d = 5;                            // dimension
        int nb = 10;                       // database size
        int nq = 10000;                        // nb of queries

//        float[] xb = new float[d * nb];
//        float[] xq = new float[d * nq];
        try {
            floatArray xb = new floatArray(d * nb);

            Random rand = new Random();

            for (int i = 0; i < nb; i++) {
                for (int j = 0; j < d; j++) {
//                xb[d * i + j] = rand.nextFloat();
                    xb.setitem(d * i + j, rand.nextFloat());
                }
//            xb[d * i] += i / 1000.;
                xb.setitem(d * i, (float) (i / 1000.0));
            }

            IndexFlatL2 index = new IndexFlatL2(d);
            log.info("is_trained = {}", index.getIs_trained());
            index.add(nb, xb.cast());
            log.info("ntotal = {}", index.getNtotal());


//            long *I = new long[k * 5];
//            float *D = new float[k * 5];
            {
                int k = 4;
                longArray I = new longArray(k * 5);
                floatArray D = new floatArray(k * 5);

                log.info("search 5 first vector of xb");
                index.search(5, xb.cast(), 4, D.cast(), I.cast());
                log.info("Vectors:\n{}", toString(xb, nb, d));
                log.info("Distances:\n{}", toString(D, 5, 4));
                log.info("I:\n{}", toString(I, 5, 4));
            }
        } catch (Exception e) {
            log.error("failed", e);
        }
    }

    @Test
    public void simpleTest() {
        try {
            float[][] data = dummyData();
            int d = data[0].length;
            int numberOfVector = data.length;
            floatArray xb = makeFloatArray(data);
            longArray ids = makeLongArray(new int[]{0, 1, 2});
            IndexFlatL2 index = new IndexFlatL2(d);
            //what():  Error in virtual void faiss::Index::add_with_ids(faiss::Index::idx_t, const float*, const long int*) at Index.cpp:46: add_with_ids not implemented for this type of index

//            index.add_with_ids(3, xb.cast(), ids.cast());
            index.add(numberOfVector, xb.cast());

            log.info("ntotal = {}", index.getNtotal());

            {
                int resultSize = 3;
                float[][] queryConds = {new float[]{0, 1, 8}};

                floatArray query = makeFloatArray(queryConds);
                longArray labels = new longArray(resultSize);
                floatArray distances = new floatArray(resultSize);
                index.search(1, query.cast(), resultSize, distances.cast(), labels.cast());

                log.info("Vectors:\n{}", toString(xb, numberOfVector, d));
                log.info("Query:\n{}", toString(query, queryConds.length, queryConds[0].length));
                log.info("Distances:\n{}", toString(distances, 1, resultSize));
                log.info("Labels:\n{}", toString(labels, 1, resultSize));
            }
        } catch (Exception e) {
            log.error("failed", e);
        }
    }

    @Test
    public void testSearchRange() {
        float[][] data = dummyData();
        int d = data[0].length;
        int numberOfVector = data.length;

        try {
            floatArray xb = makeFloatArray(data);
            IndexFlatL2 index = new IndexFlatL2(d);
            index.add(numberOfVector, xb.cast());

            {
                int resultSize = 4;
                float[][] queryConds = {new float[]{0, 1, 8}};
                floatArray query = makeFloatArray(queryConds);

                RangeSearchResult re = new RangeSearchResult(resultSize);
                int querySize = queryConds.length;
                index.range_search(querySize, query.cast(), 0.3f, re);

                longArray labels = longArray.frompointer(re.getLabels());
                floatArray distances = floatArray.frompointer(re.getDistances());

                log.info("Vectors:\n{}", toString(xb, numberOfVector, d));
                log.info("Query:\n{}", toString(query, querySize, queryConds[0].length));
                log.info("Distances:\n{}", toString(distances, querySize, resultSize));
                log.info("Labels:\n{}", toString(labels, querySize, resultSize));
            }

        } catch (Exception e) {
            log.error("failed", e);
        }
    }


    private static float[][] dummyData() {
        return new float[][]{
            new float[]{10, 0, 0},
            new float[]{9, 0, 0},
            new float[]{8, 0, 0},
            new float[]{7, 0, 0},
            new float[]{6, 0, 0},

            new float[]{0, 10, 0},
            new float[]{0, 9, 0},
            new float[]{0, 8, 0},
            new float[]{0, 7, 0},
            new float[]{0, 6, 0},

            new float[]{0, 0, 10},
            new float[]{0, 0, 9},
            new float[]{0, 0, 8},
            new float[]{0, 0, 7},
            new float[]{0, 0, 6},
        };
    }
}
