use std::fs::read_to_string;
use std::env::args;
use std::collections::HashSet;

/// Reads a file consisting of integers separated by whitespace, and returns
/// a vector of the integers.
fn read_file_of_numbers(filename: &String) -> Vec<i32> {
    read_to_string(filename)
        .unwrap()
        .split_whitespace()
        .map(|x| x.parse::<i32>().unwrap())
        .collect()
}

/// Given a vector of integers, sums its elements one-by-one. When a particular
/// sum is encountered for a second time, that sum is returned. The vector
/// cycles until such a sum is found. This could loop forever.
fn find_first_dup_while_summing(items: &Vec<i32>) -> i32 {
    // Use a set to keep track of the sums already encountered.
    let mut sums_already_encountered: HashSet<i32> = HashSet::new();
    let mut current_sum: i32 = 0;

    for item in items.iter().cycle() {
        current_sum += item;
        if sums_already_encountered.contains(&current_sum) {
            return current_sum;
        }
        sums_already_encountered.insert(current_sum);
    }

    panic!();
}

fn main() {
    // Get filename from command-line arguments
    let argv: Vec<String> = args().collect();
    let filename = argv.get(1).expect("must provide a filename");

    // Read the file
    let numbers = read_file_of_numbers(filename);

    // Sum them and print
    let sum = numbers.iter().sum::<i32>();
    println!("Sum: {}", sum);

    // Find first duplicate and print
    let first_dup = find_first_dup_while_summing(&numbers);
    println!("First duplicate: {}", first_dup);
}