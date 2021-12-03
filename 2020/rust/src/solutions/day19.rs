use lazy_static::lazy_static;
use regex::Regex;
use std::collections::HashMap;
use std::convert::TryFrom;

type RuleID = u16;

/// How a given rule should be resolved.
#[derive(Debug, Clone, PartialEq)]
enum Resolver {
    Literal(char),
    // Vec of disjuntions of conjunctions
    Dep(Vec<Vec<RuleID>>),
}

impl TryFrom<&str> for Resolver {
    type Error = &'static str;
    fn try_from(s: &str) -> Result<Self, Self::Error> {
        lazy_static! {
            static ref CHARACTER: Regex = Regex::new("\"([a-z])\"").unwrap();
        }
        if let Some(cap) = CHARACTER.captures(s) {
            let c = cap
                .get(1)
                .ok_or("No Character matches")?
                .as_str()
                .parse()
                .unwrap();
            Ok(Resolver::Literal(c))
        } else {
            // dependency
            let dep = s
                .split("|")
                .map(|group| group.split(" ").flat_map(|num| num.parse().ok()).collect())
                .collect();
            Ok(Resolver::Dep(dep))
        }
    }
}

#[derive(Debug, Clone, PartialEq)]
struct Rule {
    id: RuleID,
    resolver: Resolver,
}

impl TryFrom<&str> for Rule {
    type Error = &'static str;
    fn try_from(s: &str) -> Result<Self, Self::Error> {
        lazy_static! {
            static ref RULE: Regex = Regex::new(r"(\d+): (.*)").unwrap();
        }
        let caps = RULE.captures(s).unwrap();
        let rule_num = caps.get(1).unwrap().as_str().parse().unwrap();
        let resolver = caps.get(2).unwrap().as_str();
        let resolved = Resolver::try_from(resolver).unwrap();
        Ok(Rule::new(rule_num, resolved))
    }
}

impl Rule {
    fn new(id: RuleID, resolver: Resolver) -> Rule {
        Rule { id, resolver }
    }
}

#[derive(Debug, Clone)]
struct Manifest {
    rules: HashMap<RuleID, Rule>,
    texts: Vec<String>,
}

impl Manifest {
    fn new(rules: HashMap<RuleID, Rule>, texts: Vec<String>) -> Manifest {
        Manifest { rules, texts }
    }

    fn update_rule(&mut self, id: RuleID, resolver: Resolver) {
        let new_rule = Rule::new(id, resolver);
        self.rules.insert(id, new_rule);
    }

    fn does_match_rules(&self, text: &str) -> bool {
        type Key<'x> = (&'x [char], RuleID);

        fn does_match_multiple<'a>(
            memo: &mut HashMap<Key<'a>, bool>,
            man: &Manifest,
            chars: &'a [char],
            rules: &[RuleID],
        ) -> bool {
            let no_chars = chars.is_empty();
            let no_rules = rules.is_empty();
            if no_chars && no_rules {
                return true;
            }
            if no_chars {
                return false;
            }
            if no_rules {
                return false;
            }

            let other_rules = &rules[1..];
            for idx in 0..chars.len() {
                let idx = idx + 1;
                if does_match_single(memo, man, &chars[..idx], rules[0])
                    && does_match_multiple(memo, man, &chars[idx..], &other_rules)
                {
                    return true;
                }
            }

            false
        }

        fn does_match_single<'a>(
            memo: &mut HashMap<Key<'a>, bool>,
            man: &Manifest,
            chars: &'a [char],
            rule: RuleID,
        ) -> bool {
            let key = (chars, rule);
            if let Some(result) = memo.get(&key) {
                return *result;
            }
            let rule = man.rules.get(&rule).unwrap();

            match &rule.resolver {
                Resolver::Literal(c) => {
                    let is_match = [*c] == chars;
                    memo.insert(key, is_match);
                    is_match
                }
                Resolver::Dep(dep) => {
                    for conjunction in dep {
                        if does_match_multiple(memo, man, chars, conjunction) {
                            memo.insert(key, true);
                            return true;
                        }
                    }
                    memo.insert(key, false);
                    false
                }
            }
        }

        let chars = text.chars().into_iter().collect::<Vec<_>>();
        let chars = chars.as_slice();
        // memoization for the dynamic programming algorithm
        let mut dp = HashMap::<Key, bool>::new();
        does_match_single(&mut dp, self, &chars, 0)
    }

    fn match_count(&self) -> usize {
        self.texts
            .iter()
            .filter(|t| self.does_match_rules(t))
            .count()
    }
}

impl TryFrom<&str> for Manifest {
    type Error = &'static str;
    fn try_from(s: &str) -> Result<Self, Self::Error> {
        let mut parts = s.split("\n\n").into_iter();
        let rules = parts.next().unwrap();
        let rules = rules
            .lines()
            .flat_map(|line| Rule::try_from(line).ok())
            .map(|rule| (rule.id, rule))
            .collect();
        let texts = parts.next().unwrap();
        let texts = texts.lines().map(|line| line.to_string()).collect();
        Ok(Manifest::new(rules, texts))
    }
}

#[aoc_generator(day19)]
fn parse_input(input: &str) -> Manifest {
    Manifest::try_from(input).unwrap()
}

#[aoc(day19, part1)]
fn part1(input: &Manifest) -> usize {
    input.match_count()
}

#[aoc(day19, part2)]
fn part2(input: &Manifest) -> usize {
    let mut input = input.clone();
    input.update_rule(8, Resolver::Dep(vec![vec![42], vec![42, 8]]));
    input.update_rule(11, Resolver::Dep(vec![vec![42, 31], vec![42, 11, 31]]));
    input.match_count()
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn example() {
        let p = "0: 1 | 1 0
1: \"a\"

a
aaa
aaaaaab
b";
        let man = Manifest::try_from(p).unwrap();
        println!("{:?}", man);
        assert_eq!(man.match_count(), 2);
    }
}
