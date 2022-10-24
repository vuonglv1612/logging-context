from .base import BaseContext

__all__ = ["get_logging_context"]


def get_logging_context() -> BaseContext:
    try:
        import contextvars
    except ImportError:
        from .threadlocal import ThreadLocalContext

        return ThreadLocalContext()
    else:
        from .contextvar import ContextVarsContext

        return ContextVarsContext()
