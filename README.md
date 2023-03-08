# 目標
・terraformについての理解、チュートリアルや参考サイトを通してlocalstackを使用した開発環境での動作確認ができるようにする。
・まずはlambda->s3の構築について
・ファイル構成を意識してterraformの開発をしたい

# terraform tutorials
    https://developer.hashicorp.com/terraform/tutorials

# 想定環境
Macでの環境を想定

# Version
    Terraform v1.2.9
    on darwin_amd64
    
# terraform コマンド
1. プラグインのダウンロード

    `terraform init`

1. terraformのフォーマット

    `terraform fmt`

1. terraformの検証

    `terraform validate`

1. 作成した環境のセットアップ
    
    `terraform apply` -> yes

1. 作成した環境の削除

    `terraform destroy` -> yes

