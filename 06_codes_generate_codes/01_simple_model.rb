# 次の仕様を満たす、SimpleModelモジュールを作成してください
#
# 1. include されたクラスがattr_accessorを使用すると、以下の追加動作を行う
#   1. 作成したアクセサのreaderメソッドは、通常通りの動作を行う
#   2. 作成したアクセサのwriterメソッドは、通常に加え以下の動作を行う
#     1. 何らかの方法で、writerメソッドを利用した値の書き込み履歴を記憶する
#     2. いずれかのwriterメソッド経由で更新をした履歴がある場合、 `true` を返すメソッド `changed?` を作成する
#     3. 個別のwriterメソッド経由で更新した履歴を取得できるメソッド、 `ATTR_changed?` を作成する
#       1. 例として、`attr_accessor :name, :desc`　とした時、このオブジェクトに対して `obj.name = 'hoge` という操作を行ったとする
#       2. `obj.name_changed?` は `true` を返すが、 `obj.desc_changed?` は `false` を返す
#       3. 参考として、この時 `obj.changed?` は `true` を返す
# 2. initializeメソッドはハッシュを受け取り、attr_accessorで作成したアトリビュートと同名のキーがあれば、自動でインスタンス変数に記録する
#   1. ただし、この動作をwriterメソッドの履歴に残してはいけない
# 3. 履歴がある場合、すべての操作履歴を放棄し、値も初期状態に戻す `restore!` メソッドを作成する

module SimpleModel
  def self.included(base)
    base.extend ClassMethods
  end

  def initialize(args)
    args.each do |k, v|
      instance_variable_set("@#{k}", v)
    end
  end
  module ClassMethods
    def attr_accessor(*attributes)
      attributes.each do |attribute|
        # writer
        define_method "#{attribute}=" do |value|
          arr = instance_variable_get("@#{attribute}_array") || []
          arr << value
          instance_variable_set("@#{attribute}_array", arr)

          define_singleton_method "restore!" do
            attributes.each do |a|
              instance_variable_set("@#{a}_array", nil)
            end
          end
        end

        define_method attribute do
          instance_variable_get("@#{attribute}_array")&.last || instance_variable_get("@#{attribute}")
        end

        define_method "#{attribute}_changed?" do
          !!instance_variable_get("@#{attribute}_array")
        end
      end

      define_method "changed?" do
        attributes.any? do |attribute|
          !!instance_variable_get("@#{attribute}_array")
        end
      end
    end
  end
end