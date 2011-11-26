function out = cosine(u, v)
out = trace(u' * v) / (norm(u, 'fro') * norm(v, 'fro'));
