# Python Logging Context

[![Imports: isort](https://img.shields.io/badge/%20imports-isort-%231674b1?style=flat&labelColor=ef8336)](https://pycqa.github.io/isort/)
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)


## 1. Description
```python
import logging
from logging_context import get_logging_context, setup_logging_context
from logging_context.formatter import LoggingContextFormatter

logger = logging.getLogger("your_logger")
logger.setLevel(logging.INFO) 

handler = logging.StreamHandler()
handler.setFormatter(LoggingContextFormatter("%(asctime)s - %(name)s - %(levelname)s - context=%(context)s - %(message)s"))
handler.setLevel(logging.INFO)

logger.addHandler(handler)

logger.info("before setup")
# 2021-11-30 16:49:52,060 - your_logger - INFO - context=None - before setup
context = get_logging_context()
setup_logging_context(context)
logger.info("after setup")
# 2021-11-30 16:50:12,916 - your_logger - INFO - context={} - after setup
context.set_value("var", 100)
logger.info("after set value")
# 2021-11-30 16:50:36,562 - your_logger - INFO - context={"var": 100} - after set value
context.set_value("var", 200)
logger.info("after change value")
# 2021-11-30 16:50:53,912 - your_logger - INFO - context={"var": 200} - after change value
context.delete_value("var")
logger.info("after delete value")
# 2021-11-30 16:51:18,369 - your_logger - INFO - context={} - after delete value
```

## 2. Installation
```bash
pip install logging-context
```

## 3. Usage
### 3.1 Setup logging record factory
Function `setup_logging_context` will add a `record.context` attribute into your log record.

If you don't run the function, logging can't found any attribute `context` and raise `KeyError` exception.
```python
from logging_context import get_logging_context, setup_logging_context
context = get_logging_context()
setup_logging_context(context)
```
### 3.2 Setup logging format
Function `setup_logging_context` will add a `record.context` attribute into your log record.  
You can add `%(context)s` into your log format to show entire context values in your log  
You should use `LoggingContextFormatter` instead of default `logging.Formatter`. `LoggingContextFormatter` added `record.context` to your log record by default.
```python
context = get_logging_context()
context.set_value("var1", 200)
context.set_value("var2", "var2 value")

handler = logging.StreamHandler()
handler.setFormatter(LoggingContextFormatter("%(asctime)s - %(name)s - %(levelname)s - context=%(context)s - %(message)s"))
logger.addHandler(handler)

logger.info("log message")
# 2021-11-30 17:08:14,263 - your_logger - INFO - context={"var1": 200, "var2": "var2 value"} - log message
```
### 3.3 Context object
Wherever you want to use context, you should call function `get_logging_context` to get current context
```python
from logging_context import get_logging_context
context = get_logging_context()
```

You can set/update/delete any context value and you can clear any values of your context
```python
logger.info("before set value")
# 2021-11-30 17:12:40,413 - your_logger - INFO - context={} - before set value
context.set_value("var1", 200)
context.set_value("var2", "var2 value")
logger.info("after set value")
# 2021-11-30 17:13:09,508 - your_logger - INFO - context={"var1": 200, "var2": "var2 value"} - after set value
context.set_value("var1", 100)
logger.info("after change value")
# 2021-11-30 17:14:20,317 - your_logger - INFO - context={"var1": 100, "var2": "var2 value"} - after change value
context.delete_value("var2")
logger.info("after delete value")
# 2021-11-30 17:14:52,383 - your_logger - INFO - context={"var1": 100} - after delete value

context.set_value("var1", 150)
context.set_value("var2", "var2 value")
# 2021-11-30 17:16:05,623 - your_logger - INFO - context={"var1": 150, "var2": "var2 value"} - before clean
context.clean()
logger.info("after clean")
# 2021-11-30 17:16:45,567 - your_logger - INFO - context={} - after clean

```


## Development
  
Clone this project and run following commands to setup environment

```bash
cd logging_context
make virtualenv
source .venv/bin/activate
make install
```
