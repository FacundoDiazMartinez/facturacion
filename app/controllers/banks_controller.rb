class BanksController < ApplicationController
  before_action :set_bank

  def new_extraction

  end

  def extract
    respond_to do |format|
      if @bank.extract_amount(params)
        format.html { redirect_to [:payments, :bank_payments], notice: "Extracciñon registrado con éxito"}
      else
        format.html { redirect_to [:payments, :bank_payments], alert: "Error al registrar el extracción"}
      end
    end
  end

  private
  def set_bank
    @bank = current_user.company.banks.find(params[:id])
  end
end
