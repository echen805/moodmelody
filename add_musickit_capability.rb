#!/usr/bin/env ruby

require 'xcodeproj'

# Open the project
project_path = 'moodmelodyv2.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the main target
target = project.targets.find { |t| t.name == 'moodmelodyv2' }

if target
  puts "Found target: #{target.name}"
  
  # Add MusicKit capability
  target.add_system_capability('com.apple.MusicKit')
  
  # Save the project
  project.save
  puts "✅ MusicKit capability added successfully!"
else
  puts "❌ Could not find moodmelodyv2 target"
end 