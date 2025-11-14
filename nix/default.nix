{
  python3Packages,
  fetchFromGitHub,
  glib,
  pango,
  fontconfig,
  lib,
  stdenv,
  replaceVars,
}:

python3Packages.buildPythonApplication rec {
  pname = "weasyprint";
  version = "51.post1"; # Should match PEP 440
  pyproject = true;
  disabled = with python3Packages; pythonOlder "3.5";

  # ignore failing flake8-test
  prePatch = ''
    substituteInPlace setup.cfg \
        --replace '[tool:pytest]' '[tool:pytest]\nflake8-ignore = E501'
  '';

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
  ];

  enabledTests = [
    "test_linear_gradients_1"
  ];

  FONTCONFIG_FILE = "${fontconfig.out}/etc/fonts/fonts.conf";

  propagatedBuildInputs = with python3Packages; [ setuptools cairosvg pyphen cffi cssselect lxml html5lib tinycss pygobject3 ];

  patches = [
    ./disable-pytest-runner.patch
    (replaceVars ./library-paths.patch {
      fontconfig = "${fontconfig.lib}/lib/libfontconfig${stdenv.hostPlatform.extensions.sharedLibrary}";
      pangoft2 = "${pango.out}/lib/libpangoft2-1.0${stdenv.hostPlatform.extensions.sharedLibrary}";
      gobject = "${glib.out}/lib/libgobject-2.0${stdenv.hostPlatform.extensions.sharedLibrary}";
      pango = "${pango.out}/lib/libpango-1.0${stdenv.hostPlatform.extensions.sharedLibrary}";
      pangocairo = "${pango.out}/lib/libpangocairo-1.0${stdenv.hostPlatform.extensions.sharedLibrary}";
    })
  ];

  src = fetchFromGitHub {
    owner = "m-click";
    repo = "WeasyPrint";
    tag = "v${version}";
    hash = "sha256-B+fiSQTeHUYzRH3tjUHSiMTqr05nZOInxcuZ4O2MULs=";
  };

  meta = with lib; {
    homepage = "https://weasyprint.org/";
    description = "Converts web documents to PDF";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
  };
}
