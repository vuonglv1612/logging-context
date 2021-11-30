import io
import os
from setuptools import find_packages, setup


def read(*paths, **kwargs):
    """Read the contents of a text file safely.
    >>> read("logging_context", "VERSION")
    '0.0.1'
    >>> read("README.md")
    ...
    """

    content = ""
    with io.open(
        os.path.join(os.path.dirname(__file__), *paths),
        encoding=kwargs.get("encoding", "utf8"),
    ) as open_file:
        content = open_file.read().strip()
    return content


def read_requirements(path):
    return [
        line.strip()
        for line in read(path).split("\n")
        if not line.startswith(('"', "#", "-", "git+"))
    ]


setup(
    name="logging-context",
    version=read("logging_context", "VERSION"),
    description="Python Logging Context",
    url="https://github.com/vuonglv1612/logging-context",
    long_description=read("README.md"),
    long_description_content_type="text/markdown",
    author="vuonglv",
    extras_require={"dev": read_requirements("requirements-dev.txt")},
)