package com.sp1icer;

public class Main {

    public static void main(String[] args) {
        System.out.println(getLargestPrime(21));
        System.out.println(getLargestPrime(217));
        System.out.println(getLargestPrime(0));
        System.out.println(getLargestPrime(45));
        System.out.println(getLargestPrime(-1));
    }

    public static int getLargestPrime(int number){

        // Initial check to see if number is valid.
        if(number < 0){
            return -1;
        }

        

        // If there were no prime factors, return -1.
        return -1;
    }
}
