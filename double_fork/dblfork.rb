# Double forking example (it's forking awesome)
#
# Trying to expose the orphaned proc id the main process

read, write = IO.pipe
command = "sleep 10"

child = fork do
  read.close

  grandchild = fork do
    # Close write pipe since we don't need it, if not
    # the read in the main proc will block until this proc
    # is finished
    write.close

    # This could be anything we need executed
    begin
      exec command
    rescue SystemCallError
      puts "guess we're going to do something safe here or such"
    end
  end

  if grandchild
    Process.detach(grandchild)
  end

  write.write grandchild
  write.close

  # This first child still has the TTY of the parent, uncomment to see the
  # output show up after the main proc is done.
  #sleep 1
  #puts "The child of a child (you mean grandchild?) PID is #{grandchild}"
end

if child
  puts "Detaching Child: #{child}"
  Process.detach(child)
end

write.close

grandchild = read.read
read.close

# Finally we can see the PID of the grandchild incase we need to track it
puts "The grandchild PID is #{grandchild}"

