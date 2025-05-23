from github import Github
import requests
from typing import List, Dict, Optional

class GitHubManager:
    def __init__(self, token: str):
        self.github = Github(token)
        self.token = token
        
    def get_user(self):
        """現在のユーザー情報を取得"""
        return self.github.get_user()
    
    def get_repositories(self, sort: str = 'updated', limit: int = 50):
        """リポジトリ一覧を取得"""
        user = self.get_user()
        repos = list(user.get_repos(sort=sort))
        return repos[:limit]
    
    def get_repository_stats(self, repo_name: str) -> Dict:
        """指定したリポジトリの統計情報を取得"""
        user = self.get_user()
        repo = self.github.get_repo(f"{user.login}/{repo_name}")
        
        return {
            'stars': repo.stargazers_count,
            'forks': repo.forks_count,
            'watchers': repo.watchers_count,
            'issues': repo.open_issues_count,
            'language': repo.language,
            'size': repo.size,
            'created_at': repo.created_at,
            'updated_at': repo.updated_at
        }
    
    def create_repository(self, name: str, description: str = "", private: bool = False):
        """新しいリポジトリを作成"""
        user = self.get_user()
        return user.create_repo(
            name=name,
            description=description,
            private=private
        )