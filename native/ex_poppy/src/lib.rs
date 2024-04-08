use std::{
    fs,
    io::Error as IoError,
    path::PathBuf,
    sync::Mutex,
};

use rustler::Error as RustlerError;
use rustler::ResourceArc;
use rustler::{Env, Term};
use thiserror::Error;

pub struct BloomFilter (
   Mutex<poppy::BloomFilter>
);

#[derive(Error, Debug)]
pub enum ExPoppyError {
    #[error("IO error: {0}")]
    IoError(#[from] IoError),
    #[error("Poppy error: {0}")]
    PoppyError(#[from] poppy::Error),
}

impl From<ExPoppyError> for RustlerError {
    fn from(e: ExPoppyError) -> Self {
        RustlerError::Term(Box::new(e.to_string()))
    }
}

fn load(env: Env, _: Term) -> bool {
    rustler::resource!(BloomFilter, env);
    true
}

#[rustler::nif]
pub fn new(c: usize, fp: f64) -> ResourceArc<BloomFilter> {
    ResourceArc::new(BloomFilter (
        Mutex::new(poppy::BloomFilter::with_capacity(c, fp)),
    ))
}

#[rustler::nif]
pub fn with_version(v: u8, c: usize, fp: f64) -> Result<ResourceArc<BloomFilter>, RustlerError>  {
    Ok(ResourceArc::new(BloomFilter (
        Mutex::new(poppy::BloomFilter::with_version_capacity(v, c, fp).map_err(ExPoppyError::from)?),
    )))
}

/// TODO with params

#[rustler::nif]
/// Insert a str into the filter
pub fn insert_str(bf: ResourceArc<BloomFilter>, s: &str) -> Result<bool, RustlerError> {
    Ok(bf.0.lock().unwrap().insert_bytes(s).map_err(ExPoppyError::from)?)
}

/// Check if argument is contained in the filter
#[rustler::nif]
pub fn contains_str(bf: ResourceArc<BloomFilter>, s: &str) -> bool {
    bf.0.lock().unwrap().contains_bytes(s)
}

#[rustler::nif]
pub fn load_filter(path: String) -> Result<ResourceArc<BloomFilter>, RustlerError> {
    let path = PathBuf::from(path);
    let bf = poppy::BloomFilter::from_reader(fs::File::open(&path).map_err(ExPoppyError::from)?)
        .map_err(ExPoppyError::from)?;

    Ok(ResourceArc::new(BloomFilter (Mutex::new(bf))))
}

#[rustler::nif]
pub fn version(bf: ResourceArc<BloomFilter>) -> u8 {
    bf.0.lock().unwrap().version() as u8
}

#[rustler::nif]
pub fn capacity(bf: ResourceArc<BloomFilter>) -> usize {
    bf.0.lock().unwrap().capacity()
}

#[rustler::nif]
pub fn fpp(bf: ResourceArc<BloomFilter>) -> f64 {
    bf.0.lock().unwrap().fpp()
}

#[rustler::nif]
pub fn count_estimate(bf: ResourceArc<BloomFilter>) -> usize {
    bf.0.lock().unwrap().count_estimate() as usize
}

#[rustler::nif]
pub fn data(bf: ResourceArc<BloomFilter>) -> Vec<u8> {
    bf.0.lock().unwrap().data().to_vec()
}

rustler::init!(
    "Elixir.ExPoppy",
    [
        new,
        with_version,
        insert_str,
        contains_str,
        version,
        capacity,
        fpp,
        count_estimate,
        data,
        load_filter
    ],
    load = load
);
