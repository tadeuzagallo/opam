(**************************************************************************)
(*                                                                        *)
(*    Copyright 2012-2015 OCamlPro                                        *)
(*    Copyright 2012 INRIA                                                *)
(*                                                                        *)
(*  All rights reserved. This file is distributed under the terms of the  *)
(*  GNU Lesser General Public License version 2.1, with the special       *)
(*  exception on linking described in the file LICENSE.                   *)
(*                                                                        *)
(**************************************************************************)

(** URL parsing and printing, with support for our different backends *)

type version_control = [ `git | `darcs | `hg ]

type backend = [ `http | `rsync | version_control ]

val string_of_backend: backend -> string

(** Tolerates lots of backward compatibility names;
    @raise Failure on unknown protocol *)
val backend_of_string: string -> [> backend]

type t = {
  transport: string; (** the part just before '://' *)
  path: string; (** the part after '://' *)
  hash: string option; (** the optional branch/ref specification,
                           at the end after a '#' *)
  backend: backend; (** the backend that opam should use to handle this
                        url *)
}

(** Same as [of_string], but allows enforcing the expected backend, and may
    otherwise guess version control from the suffix by default (for e.g.
    https://foo/bar.git) (this should be disabled when parsing from files) *)
val parse: ?backend:backend -> ?handle_suffix:bool -> string -> t

include OpamStd.ABSTRACT with type t := t

(** Dummy filler url *)
val empty: t

(** Returns the url string without the VC part (i.e. "git+foo://bar" returns
    "foo://bar") *)
val base_url: t -> string

(** The last part of the url path, e.g. ["http://foo/bar/this"] or
    ["http://that.here/"] *)
val basename: t -> string

(** Returns the url with all path components but the first one (the hostname)
    dropped, e.g. ["http://some.host/some/path"] becomes ["http://some.host"] *)
val root: t -> t

val has_trailing_slash: t -> bool

(** Check if the URL matches an existing local directory, and return it *)
val local_dir: t -> OpamFilename.Dir.t option

(** Check if the URL matches an existing local file, and return it *)
val local_file: t -> OpamFilename.t option

(** If the given url-string has no 'transport://' specification and corresponds
    to an existing local path, check for version-control clues at that path *)
val guess_version_control: string -> [> version_control ] option

module Op: sig

  (** Appends at the end of an URL path with '/' separator. Gets back to the
      root if the second argument starts with '/' *)
  val ( / ) : t -> string -> t

end
