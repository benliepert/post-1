extern crate cbindgen;

use std::env;

fn main() {
    let crate_dir = env::var("CARGO_MANIFEST_DIR").unwrap();

    cbindgen::Builder::new()
      .with_crate(crate_dir)
      .with_language(cbindgen::Language::Cxx)
      .generate()
      .expect("Unable to generate bindings")
      .write_to_file("include/rust_toy.h");

    println!("cargo:rerun-if-changed=src/lib.rs");
}