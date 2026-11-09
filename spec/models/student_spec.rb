require 'rails_helper'

RSpec.describe Student, type: :model do
  describe 'validacoes e criacao' do
    it 'e valido quando possui nome, matricula e saldo' do
      student = Student.new(name: 'Alice', registration: '123456', balance: 10.0)
      expect(student).to be_valid
    end
    it 'permite consultar o saldo corretamente' do
      student = Student.create!(name: 'Bob', registration: '6544321', balance: 2.0)
      expect(student.balance).to eq(2.0)
    end
  end
end
