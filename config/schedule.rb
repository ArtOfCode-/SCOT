every 1.day, at: '14:00' do
  runner 'Broadcast::Item.save_script'
end

every 1.day, at: '00:00' do
  runner 'Broadcast::Item.save_script'
end