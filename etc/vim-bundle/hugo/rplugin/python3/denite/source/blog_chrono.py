from .base import Base
import subprocess
from denite.util import abspath

class Source(Base):
    def __init__(self, vim):
        super().__init__(vim)

        self.name = 'blog_chrono'
        self.kind = 'file'

    def gather_candidates(self, context):
        out = subprocess.run([
            'bin/q', '--sql',
            'SELECT filename FROM articles ORDER BY date desc'],
            stdout=subprocess.PIPE)

        return [{'word': x, 'abbr': x, 'action__path': abspath(self.vim, x) }
                for x in out.stdout.decode("ascii").split("\n")]
