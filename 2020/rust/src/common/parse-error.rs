use std::str::FromStr;
use std::{
    error::Error,
    fmt::{self, Display, Formatter},
    num::ParseIntError,
    char::ParseCharError,
};

#[derive(Debug, Clone)]
pub struct ParseError;

impl Display for ParseError {
    fn fmt(&self, f: &mut Formatter) -> fmt::Result {
        write!(f, "Unable to parse input.")
    }
}

impl Error for ParseError {
    fn description(&self) -> &str {
        "Unable to parse input."
    }

    fn cause(&self) -> Option<&dyn Error> {
        None
    }
}

impl From<ParseIntError> for ParseError {
    fn from(_error: ParseIntError) -> Self {
        ParseError
    }
}

impl From<ParseCharError> for ParseError {
    fn from(_error: ParseIntError) -> Self {
        ParseError
    }
}
