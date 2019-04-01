package com.thenetcircle.services.faiss4j.tests;

import org.junit.BeforeClass;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.nio.file.Paths;

public class IOTests {
    private static final Logger log = LoggerFactory.getLogger(IOTests.class);

    @BeforeClass
    public static void load() {
        System.load(Paths.get("./swigfaiss4j.so").toAbsolutePath().toString());
        System.loadLibrary("faiss");
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

    @Test
    public void testIndexWriteAndRead() {
        String filename = "./index-1";


    }
}
