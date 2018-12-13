use std::collections::HashMap;

#[derive(PartialEq, Eq, Debug, Hash, Clone, Copy)]
struct Point {
    x: i32,
    y: i32
}

impl Point {
    fn new(x: i32, y: i32) -> Point {
        Point { x, y }
    }
}

#[derive(Debug)]
struct Grid {
    width: i32,
    height: i32,
    serial_number: i32,
    power_level_cache: HashMap<Point, i32>
}

impl Grid {
    fn new(width: i32, height: i32, serial_number: i32) -> Grid {
        Grid { width, height, serial_number, power_level_cache: HashMap::new() }
    }

    fn power_level(&mut self, point: Point) -> i32 {
        let mut new_power_level: Option<i32> = None;

        if !self.power_level_cache.contains_key(&point) {
            new_power_level = Some(self.calc_power_level(point));
        }

        *self.power_level_cache.entry(point).or_insert_with({ || new_power_level.unwrap() })
    }

    fn calc_power_level(&self, point: Point) -> i32 {
        let rack_id = point.x + 10;
        let power_digits = (rack_id * point.y + self.serial_number) * rack_id;

        let mut digits = power_digits.to_string().chars()
            .into_iter()
            .collect::<Vec<char>>();

        digits.reverse();

        digits.get(2).and_then({ |x| x.to_digit(10) }).unwrap_or(0) as i32 - 5
    }

    fn power_level_region(&mut self, top_left: Point, width: i32, height: i32) -> i32 {
        let mut result = 0;

        for x in top_left.x..(top_left.x + width) {
            for y in top_left.y..(top_left.y + height) {
                result += self.power_level(Point::new(x, y));
            }
        }

        result
    }

    fn csv(&mut self) -> String {
        let mut result = "".to_owned();

        for y in 0..self.height {
            for x in 0..self.width {
                result += &(self.power_level(Point::new(x, y)).to_string() + ",");
            }

            result += "\n";
        }

        result.to_string()
    }
}

fn solve_part_one(input: i32) -> Point {
    let mut grid = Grid::new(300, 300, input);
    let size = 3;

    let mut curr_highest_point = Point::new(0, 0);
    let mut curr_highest_value = -999999;
    
    for x in 0..=(300 - size) {
        for y in 0..=(300 - size) {
            let reg = grid.power_level_region(Point::new(x, y), size, size);
            if reg > curr_highest_value {
                curr_highest_value = reg;
                curr_highest_point = Point::new(x, y);
            }
        }
    }

    curr_highest_point
}

fn solve_part_two(input: i32) -> (Point, i32) {
    let mut grid = Grid::new(300, 300, input);

    let mut curr_highest_point = Point::new(0, 0);
    let mut curr_highest_size = 0;
    let mut curr_highest_value = -999999;
    
    for size in 1..=300 {
        println!("{}", size);

        for x in 0..=(300 - size) {
            for y in 0..=(300 - size) {
                let reg = grid.power_level_region(Point::new(x, y), size, size);
                if reg > curr_highest_value {
                    curr_highest_value = reg;
                    curr_highest_point = Point::new(x, y);
                    curr_highest_size = size;
                }
            }
        }
    }

    (curr_highest_point, curr_highest_size)
}

fn main() {
    println!("{:?}", solve_part_one(8868));
    //println!("{}", Grid::new(300, 300, 8868).csv());   
}
