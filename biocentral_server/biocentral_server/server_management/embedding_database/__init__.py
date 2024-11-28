from .embedding_database import EmbeddingsDatabase, EmbeddingsDatabaseTriple


def init_embeddings_database_instance(app):
    """Initialize the database with the Flask app."""
    embeddings_db_instance = EmbeddingsDatabase()
    embeddings_db_instance.init_app(app)
    return embeddings_db_instance


__all__ = ['init_embeddings_database_instance', 'EmbeddingsDatabase', 'EmbeddingsDatabaseTriple']
