global class SchedulableBirthdayBatch implements Schedulable{

    global void execute(SchedulableContext sc){

        BirthdayBatch batch = new BirthdayBatch(); 

        database.executeBatch(batch);
    }

}