use poppy::Params;
use rustler::Error as RustlerError;
use rustler::ResourceArc;
use rustler::{Env, Term};
use std::{fs, io::Error as IoError, path::PathBuf, sync::Mutex};
use thiserror::Error;

pub struct BloomFilter(Mutex<poppy::BloomFilter>);

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
    let _ = rustler::resource!(BloomFilter, env);
    true
}

#[rustler::nif]
pub fn new(c: usize, fp: f64) -> ResourceArc<BloomFilter> {
    ResourceArc::new(BloomFilter(Mutex::new(poppy::BloomFilter::with_capacity(
        c, fp,
    ).expect("Failed to create bloom filter."))))
}

#[rustler::nif]
pub fn with_version(v: u8, c: usize, fp: f64) -> Result<ResourceArc<BloomFilter>, RustlerError> {
    Ok(ResourceArc::new(BloomFilter(Mutex::new(
        poppy::BloomFilter::with_version_capacity(v, c, fp).map_err(ExPoppyError::from)?,
    ))))
}

#[rustler::nif]
pub fn with_params(
    v: u8,
    c: usize,
    fp: f64,
    opt: u8,
) -> Result<ResourceArc<BloomFilter>, RustlerError> {
    let p = Params::new(c, fp).version(v).opt(
        opt.try_into()
            .map_err(poppy::Error::from)
            .map_err(ExPoppyError::from)?,
    );

    Ok(ResourceArc::new(BloomFilter(Mutex::new(
        p.try_into().map_err(ExPoppyError::from)?,
    ))))
}

#[rustler::nif]
/// Insert a str into the filter
pub fn insert_str(bf: ResourceArc<BloomFilter>, s: &str) -> Result<bool, RustlerError> {
    Ok(bf
        .0
        .lock()
        .unwrap()
        .insert_bytes(s)
        .map_err(ExPoppyError::from)?)
}

// #[rustler::nif]
// pub fn insert_bytes(&mut self, data: &[u8]) -> Result<bool, RustlerError>  {
//     Ok(bf.0.lock().unwrap().insert_bytes(data).map_err(ExPoppyError::from)?)
// }

/// Check if argument is contained in the filter
#[rustler::nif]
pub fn contains_str(bf: ResourceArc<BloomFilter>, s: &str) -> bool {
    bf.0.lock().unwrap().contains_bytes(s)
}

// #[rustler::nif]
// pub fn contains_bytes(bf: ResourceArc<BloomFilter>, data: &[u8]) -> bool {
//     bf.0.lock().unwrap().contains_bytes(data)
// }

#[rustler::nif]
pub fn load_filter(path: String) -> Result<ResourceArc<BloomFilter>, RustlerError> {
    let path = PathBuf::from(path);
    let bf = poppy::BloomFilter::from_reader(fs::File::open(&path).map_err(ExPoppyError::from)?)
        .map_err(ExPoppyError::from)?;

    Ok(ResourceArc::new(BloomFilter(Mutex::new(bf))))
}

#[rustler::nif]
/// Save filter into a file
pub fn save(bf: ResourceArc<BloomFilter>, path: String) -> Result<(), RustlerError> {
    let path = PathBuf::from(path);
    let mut f = fs::File::create(path).map_err(ExPoppyError::from)?;
    Ok(bf.0.lock().unwrap().write(&mut f).map_err(ExPoppyError::from)?)
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

// #[rustler::nif]
// pub fn data(bf: ResourceArc<BloomFilter>) -> Vec<u8> {
//     bf.0.lock().unwrap().data().to_vec()
// }

rustler::init!(
    "Elixir.ExPoppy.Native",
    load = load
);
