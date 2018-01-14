require './app/tools/z3interface/schedule'
class SurgeriesController < ApplicationController
  protect_from_forgery prepend: true, with: :exception

  def show
  	d = params[:date]
  	@surgeries = Surgery.where(date: d)
  	render 'surgeries/show'
  end

  def schedule
    @surgery = Surgery.find(params[:surgery_id])
  	@nurses = Nurse.all
  	render 'surgeries/schedule'
  end

  def addNurse

    surgery_id = params[:surgery_id]
    nurses_id = params[:nurse]

    puts(nurses_id)

    surgery = Surgery.find(surgery_id)

    # instrument_nurse.department = processDepartment(instrument_nurse.department)
    # puts(instrument_nurse.department)

    #此处应进行算法判断
    # if(true)
    #   surgery.update(instrument_nurse_id: instrument_nurse_id, roving_nurse_id: roving_nurse_id)
    # end

    nurses = Nurse.all
    for nurse in nurses 
      nurse.department = processDepartment(nurse.department)
      nurse.is_experienced = processDepartment(nurse.is_experienced)
    end

    puts(nurses.to_json)

    nursesJson = File.new("./db/json/nurses.json", "w")
    if nursesJson
      nursesJson.syswrite(nurses.to_json)
    else
      puts "Unable to open file!"
    end

    @surgeries = Surgery.where(date: surgery.date)
    render 'surgeries/show'
  end

  def getScheduleResult
      # TODO: 这里的参数暂时省略了,这些参数应该是从数据库中获取
      client_table_data_str = File.read('./app/tools/z3interface/clientTable.json')
      surgery_time_data_str = File.read("./app/tools/z3interface/surgeryTimeTable.json")
      Schedule.schedule(client_table_data_str,surgery_time_data_str)
  end

  def processDepartment(departments)
    index = 0
    result = Array.new()
    while index < 14
      if(departments[index] == "1")
        d = Department.find(index + 1)
        result.push(d.name)
      end
      index = index + 1
    end
    return result
  end

end