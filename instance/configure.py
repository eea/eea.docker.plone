import os

header = """\
[buildout]
extends = base.cfg
"""
configuration = ""
extra_buildout_configuration = ""
sources = ""

existing_types = [
    "eggs"
]

list_types = [
    "zcml",
    "products",
    "extra-paths",
    "scripts",
    "zope-conf-imports",

]

conf_types = [
    "environment-vars",
    "rel-storage",
    "event-log-custom",
    "mailinglogger",
    "access-log-custom",
    "site-zcml",
    "zcml-additional",
    "zope-conf-additional",
    "entry_points"
]

# build [instance]
for variable in os.environ:
    if "BUILDOUT_" not in variable:
        continue
    tag = variable[9:].lower().replace('_', '-')
    if tag in existing_types:
        configuration += "%s +=\n" % tag
        for value in os.environ[variable].strip('"\'').split():
            configuration += "\t%s\n" % value
    elif tag in list_types:
        configuration += "%s =\n" % tag
        for value in os.environ[variable].strip('"\'').split():
            configuration += "\t%s\n" % value
    elif tag in conf_types:
        configuration += "%s =\n" % tag
        for value in os.environ[variable].strip('"\'').split('\\n'):
            configuration += "\t%s\n" % value
    else:
        configuration += "%s = %s\n" % (tag, os.environ[variable].strip('"\''))

if "INDEX" in os.environ:
    extra_buildout_configuration += "index =\n"
    for value in os.environ["INDEX"].strip('"\'').split():
        extra_buildout_configuration += "\t%s\n" % value

if "FIND_LINKS" in os.environ:
    extra_buildout_configuration += "find-links =\n"
    for value in os.environ["FIND_LINKS"].strip('"\'').split():
        extra_buildout_configuration += "\t%s\n" % value

# build [sources]
for variable in os.environ:
    if "SOURCE_" not in variable:
        continue
    package = variable[7:].lower().replace('_', '.')
    sources += "%s = %s\n" % (package, os.environ[variable])

if extra_buildout_configuration:
    header += extra_buildout_configuration

if sources:
    header += """
[sources]
""" + sources

if configuration:
    header += """
[instance]
"""


if extra_buildout_configuration or configuration or sources:
    buildout = open("/opt/plone/buildout.cfg", "w")
    print >> buildout, header + configuration,
