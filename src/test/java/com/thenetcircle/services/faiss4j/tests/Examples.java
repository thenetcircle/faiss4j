package com.thenetcircle.services.faiss4j.tests;

import com.thenetcircle.services.faiss.IndexFlatL2;
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
            for (int j = 0; j < cols; j++) {
                sb.append(String.format("%5ld ", a.getitem(i * cols + j)));
            }
            sb.append("\n");
        }
        return sb.toString();
    }

    public static String toString(floatArray a, int rows, int cols) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < rows; i++) {
            for (int j = 0; j < cols; j++) {
                sb.append(String.format("%7g ", a.getitem(i * cols + j)));
            }
            sb.append("\n");
        }
        return sb.toString();
    }

    @Test
    public void testFlat() {
        int d = 64;                            // dimension
        int nb = 100000;                       // database size
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
                xb.setitem(d * i, i / 1000);
            }

            IndexFlatL2 index = new IndexFlatL2(d);
            log.info("is_trained = {}", index.getIs_trained());
            index.add(nb, xb.cast());
            log.info("ntotal = {}", index.getNtotal());


//            long *I = new long[k * 5];
//            float *D = new float[k * 5];
            int k = 4;
            longArray I = new longArray(k * 5);
            floatArray D = new floatArray(k * 5);

            log.info("search 5 first vector of xb");
            index.search(5, xb.cast(), 4, D.cast(), I.cast());
            log.info("D:\n{}", toString(D, 5, 4));
            log.info("I:\n{}", toString(D, 5, 4));
        } catch (Exception e) {
            log.error("failed", e);
        }
    }
}
